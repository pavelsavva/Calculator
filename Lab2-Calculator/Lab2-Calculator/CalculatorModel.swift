//
//  CalculatorModel.swift
//  Lab2-Calculator
//
//  Created by Student on 9/17/17.
//
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    private var currentOperand: Double?
    private var currentFunction: ((Double, Double) -> (Double))?
    private var memory: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals()
        case unaryMemoryOperation((inout Double) -> Void)
        case binaryMemoryOperation((inout Double, inout Double) -> Void)
        case clear()
    }
    
    private var operations: Dictionary<String, Operation> = [
        "+": Operation.binaryOperation({$0 + $1}),
        "-": Operation.binaryOperation({$0 - $1}),
        "*": Operation.binaryOperation({$0 * $1}),
        "/": Operation.binaryOperation({$0 / $1}),
        
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        
        "√": Operation.unaryOperation({sqrt($0)}),
        "cos": Operation.unaryOperation({cos($0)}),
        "sin": Operation.unaryOperation({sin($0)}),
        "tan": Operation.unaryOperation({tan($0)}),
        "cot": Operation.unaryOperation({1/tan($0)}),
        "±": Operation.unaryOperation({-$0}),
        "|x|": Operation.unaryOperation({abs(-$0)}),
        
        "=": Operation.equals(),
        "C": Operation.clear(),
        
        "MC": Operation.unaryMemoryOperation({$0 = 0}),
        
        "MR": Operation.binaryMemoryOperation({$1 = $0}),
        "MS": Operation.binaryMemoryOperation({$0 = $1}),
        "M+": Operation.binaryMemoryOperation({$0 += $1})
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            
            switch operation {
                
            case .constant(let value):
                accumulator = value
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
                
            case .binaryOperation(let function):
                if currentOperand != nil {
                    accumulator = currentFunction!(currentOperand!, accumulator!)
                    currentFunction = function
                    currentOperand = accumulator
                } else {
                    currentFunction = function
                    currentOperand = accumulator
                }
                
            case .equals():
                if currentOperand != nil {
                    accumulator = currentFunction!(currentOperand!, accumulator!)
                    currentOperand = nil
                }
                
            case .clear():
                if(accumulator == nil) {
                    currentFunction = nil
                    currentOperand = nil
                } else {
                    accumulator = nil
                }
                
            case .binaryMemoryOperation(let function):
                print(symbol)
                if accumulator != nil {
                    memory = memory ?? 0
                    function(&memory!, &accumulator!)
                }
                
            case .unaryMemoryOperation(let function):
                if memory != nil {
                    function(&memory!)
                }
                
            }
            
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
}
