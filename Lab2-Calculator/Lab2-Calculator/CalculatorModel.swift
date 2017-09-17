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
    private var oldAccumulator: Double?
    private var currentOperation: ((Double, Double) -> (Double))?
    private var lastOperation: ((Double, Double) -> (Double))?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
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
        "±": Operation.unaryOperation({-$0}),
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
                
                currentOperation = function
                if lastOperation != nil {
                    accumulator = lastOperation!(oldAccumulator!, currentOperation!)
                }
                
//                if currentOperation == nil {
//                    
//                    currentOperation = function
//                    oldAccumulator = accumulator
//                    accumulator = nil
//                    
//                } else if accumulator != nil {
//                    accumulator = currentOperation!(oldAccumulator!, accumulator!)
//                }
                
            }
            
        } else if(symbol == "=") {
            let tempAccumulator = accumulator
            accumulator = currentOperation!(oldAccumulator!, accumulator!)
            oldAccumulator = tempAccumulator
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
