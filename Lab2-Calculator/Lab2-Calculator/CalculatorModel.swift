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
    private var isNew: Bool?
    private var currentOperand: Double?
    private var currentFunction: ((Double, Double) -> (Double))?
    private var memory: Double = 0
    private var operatorsHistory = [String?]()
    private var operandsHistory = [Double?]()
    private var clearWasPressed = false
    
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
            
            var operationIsClear = false
            
            switch operation {
                
            case .constant(let value):
                accumulator = value
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
                
            case .binaryOperation(let function):
                //                if currentOperand != nil {
                //                    accumulator = currentFunction!(currentOperand!, accumulator!)
                //                    currentFunction = function
                //                    currentOperand = accumulator
                //                } else {
                //                    currentFunction = function
                //                    currentOperand = accumulator
                //                }
                
                if accumulator != nil && isNew != nil {
                    if isNew! {
                        operandsHistory.append(accumulator!)
                        operatorsHistory.append(symbol)
                    } else {
                        if operatorsHistory.isEmpty {
                            operatorsHistory.append(symbol)
                            operandsHistory.append(accumulator!)
                        } else {
                        operatorsHistory[operatorsHistory.count - 1] = symbol
                        }
                    }
                }
                accumulator = nil
                print(operatorsHistory)
                print(operandsHistory)
                
            case .equals():
                //                if currentOperand != nil {
                //                    accumulator = currentFunction!(currentOperand!, accumulator!)
                //                    currentOperand = nil
                //                }
                if accumulator != nil {
                    operandsHistory.append(accumulator!)
                    print(operatorsHistory)
                    print(operandsHistory)
                    evaluate()
                    operandsHistory = []
                    operatorsHistory = []
                    print(operatorsHistory)
                    print(operandsHistory)
                }
                
            case .clear():
                //                if(accumulator == nil) {
                //                    currentFunction = nil
                //                    currentOperand = nil
                //                } else {
                //                    accumulator = nil
                //                }
                if clearWasPressed {
                    accumulator = 0
                    operatorsHistory = []
                    operandsHistory = []
                } else {
                    clearWasPressed = true
                    accumulator = 0
                }
                operationIsClear = true
                
            case .binaryMemoryOperation(let function):
                if accumulator != nil {
                    function(&memory, &accumulator!)
                }
                
            case .unaryMemoryOperation(let function):
                function(&memory)
                
            }
            
            if operationIsClear {
                clearWasPressed = true
            }
        }
        
    }
    
    private mutating func evaluate() {
    
        var lastNumberIndex: Int = 0
        
        for (index, symbol) in operatorsHistory.enumerated() {
            if symbol == "*" {
                let validIndex = operandsHistory[index] != nil ? index : lastNumberIndex
                let currentValue = operandsHistory[index]
                
                operandsHistory[index] = operandsHistory[validIndex]! * operandsHistory[index+1]!
                if currentValue == nil {
                    operandsHistory[lastNumberIndex] = nil
                }
                operatorsHistory[index] = nil
                operandsHistory[index+1] = nil
                
                lastNumberIndex = index
            } else if symbol == "/" {
                let validIndex = operandsHistory[index] != nil ? index : lastNumberIndex
                let currentValue = operandsHistory[index]
                
                operandsHistory[index] = operandsHistory[validIndex]! / operandsHistory[index+1]!
                if currentValue == nil {
                    operandsHistory[lastNumberIndex] = nil
                }
                operatorsHistory[index] = nil
                operandsHistory[index+1] = nil
                
                lastNumberIndex = index
            } else if symbol != nil {
                lastNumberIndex = index
            }
        }
        
        accumulator = nil
        operandsHistory = operandsHistory.filter { $0 != nil }
        operatorsHistory = operatorsHistory.filter { $0 != nil }
        print(operandsHistory)
        print(operatorsHistory)
        
        for (index, symbol) in operatorsHistory.enumerated() {
            if symbol == "+" {
                if accumulator == nil {
                    accumulator = operandsHistory[index]
                }
                accumulator! += operandsHistory[index+1]!
            } else if symbol == "-" {
                if accumulator == nil {
                    accumulator = operandsHistory[index]
                }
                accumulator! -= operandsHistory[index+1]!
            }
        }
        
        accumulator = accumulator ?? operandsHistory[operandsHistory.count - 1]
        
        print(accumulator)
    }
    
    
    mutating func setOperand(_ operand: Double, _ isNew: Bool) {
        accumulator = operand
        self.isNew = isNew
    }
    
    public func getHistory() -> String {
        var string = ""
        for (index, symbol) in operatorsHistory.enumerated() {
            string += "\((operandsHistory[index]!.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(operandsHistory[index]!))" : "\(Double(operandsHistory[index]!))"))\(symbol!)"
        }
        
        return string
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
}
