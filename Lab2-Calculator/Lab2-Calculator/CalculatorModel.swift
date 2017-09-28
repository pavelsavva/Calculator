//
//  CalculatorModel.swift
//  Lab2-Calculator
//
//  Created by Pavel Savva on 9/17/17.
//
//

import Foundation

struct CalculatorBrain {
    
    private var memory: String
    private var inputSequence = [String]()
    private var evaluationSequence = [String]()
    
    //Current state of the calculator brain
    public private (set) var calculatorState: State
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals()
        case unaryMemoryOperation((inout String) -> Void)
        case binaryMemoryOperation((inout String, String) -> Void)
        case clear()
        case decimal()
        case memoryRestore()
    }
    
    //States of the calculator brain
    public enum State {
        case precalculated
        case calculated
        case binary
        case unary
        case cleared
        case decimal
        case precleared
    }
    
    init() {
        calculatorState = .calculated
        memory = "0"
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
        "ln": Operation.unaryOperation({log($0)}),
        
        "=": Operation.equals(),
        "C": Operation.clear(),
        ".": Operation.decimal(),
        
        "MC": Operation.unaryMemoryOperation({$0 = "0"}),
        
        "MR": Operation.memoryRestore(),
        
        "MS": Operation.binaryMemoryOperation({$0 = $1}),
        "M+": Operation.binaryMemoryOperation({
            let result = Double($0)! + Double($1)!
            $0 = result.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(result))" : "\(Double(result))"
        })
    ]
    
    private var binaryOperatorsPrecedence: Dictionary<String, Int> = [
        "+": 0,
        "-": 0,
        "*": 1,
        "/": 1
    ]
    
    /**
     This adds the input operand to the current operator sequence.
     */
    mutating public func setOperand(_ operand: String) {
        
        if Int(operand) != nil {
            
            switch calculatorState {
                
                case .calculated:
                    inputSequence = []
                    fallthrough
                
                case .binary,
                     .unary,
                     .cleared,
                     .precleared:
                    inputSequence.append(operand)
                    calculatorState = .precalculated
                
                case .precalculated:
                    if Double(inputSequence[inputSequence.count -  1]) != nil && inputSequence[inputSequence.count -  1] != "0"{
                        inputSequence[inputSequence.count -  1] += operand
                    } else {
                        inputSequence[inputSequence.count -  1] = operand
                    }
                    calculatorState = .precalculated
                
                case .decimal:
                    inputSequence[inputSequence.count -  1] += ".\(operand)"
                    calculatorState = .precalculated
                
            }
            
        } else if let operation = operations[operand] {
            
            switch operation {
                
                case .constant(_):
                    switch calculatorState {
                    case .calculated:
                        inputSequence = []
                        fallthrough
                    case .binary,
                         .unary,
                         .cleared,
                         .precleared:
                        inputSequence.append(operand)
                        calculatorState = .precalculated
                    case .precalculated,
                         .decimal:
                        inputSequence[inputSequence.count - 1] = operand
                        calculatorState = .precalculated
                    }
                
                case .unaryOperation(_):
                    switch calculatorState {
                    case .calculated:
                        inputSequence = []
                        fallthrough
                    case .binary,
                         .cleared,
                         .unary,
                         .precleared:
                        inputSequence.append(operand)
                        calculatorState = .unary
                    case .precalculated,
                         .decimal:
                        break
                    }
                
                case .binaryOperation(_):
                    switch calculatorState {
                    case .precalculated,
                         .precleared:
                        inputSequence.append(operand)
                        calculatorState = .binary
                    case .binary:
                        inputSequence[inputSequence.count - 1] = operand
                    case .unary,
                         .decimal,
                         .calculated,
                         .cleared:
                        break
                    }
                
                case .equals:
                    if calculatorState == .precalculated {
                        calculatorState = .calculated
                    }
                
                case .unaryMemoryOperation(let function):
                    function(&memory)
                
                case .binaryMemoryOperation(let function):
                    if calculatorState == .precalculated || calculatorState == .calculated {
                        function(&memory, getResult())
                    }
                
                case .memoryRestore() :
                    switch calculatorState {
                    case .calculated:
                        inputSequence = []
                        fallthrough
                    case .binary,
                         .unary,
                         .cleared,
                         .precleared:
                        inputSequence.append(memory)
                        calculatorState = .precalculated
                    case .precalculated,
                         .decimal:
                        inputSequence[inputSequence.count - 1] = memory
                        calculatorState = .precalculated
                    }
                
                case .clear:
                    if calculatorState == .precleared {
                        inputSequence = []
                        calculatorState = .cleared
                    } else if calculatorState != .cleared {
                        inputSequence.remove(at: inputSequence.count - 1)
                        calculatorState = .precleared
                    }
                
                case .decimal:
                    switch calculatorState {
                    case .calculated:
                        inputSequence = []
                        fallthrough
                    case .cleared,
                         .binary,
                         .unary,
                         .precleared:
                        inputSequence.append("0")
                        calculatorState = .decimal
                    case .precalculated:
                        if !inputSequence[inputSequence.count - 1].contains(".") && Double(inputSequence[inputSequence.count -  1]) != nil {
                            calculatorState = .decimal
                        }
                    case .decimal:
                        break
                    }
                
            }
            
        }
        
    }
    
    /**
     This method return the result that the current operator sequence evaluates to.
     */
    mutating public func getResult() -> String {
        
        if calculatorState == .precalculated || calculatorState == .calculated{
            
            evaluateOperators()
            
            let result = evaluate(evaluationSequence.first!, 0)
            
            return (result.0.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(result.0))" : "\(Double(result.0))")
            
        } else {
            return ""
        }
    }
    
    /**
     This method returns the current operator sequence.
     */
    public func getHistory() -> [(String)] {
        return inputSequence
    }
    
    mutating private func evaluateOperators() {
        evaluationSequence = []
        
        for operand in inputSequence {
            
            if Double(operand) != nil {
                
                evaluationSequence.append(operand)
                
            } else if let operation = operations[operand] {
                
                switch operation {
                case .constant(_):
                    evaluationSequence.append(operand)
                case .unaryOperation(_):
                    evaluationSequence.append(operand)
                case .binaryOperation(_):
                    if let precedence = binaryOperatorsPrecedence[operand] {
                        if precedence == 0 {
                            evaluationSequence.insert(operand, at: 0)
                        } else if precedence == 1 {
                            evaluationSequence.insert(operand, at: evaluationSequence.count - 1)
                        }
                    }
                case .equals,
                     .unaryMemoryOperation(_),
                     .binaryMemoryOperation(_),
                     .clear,
                     .decimal,
                     .memoryRestore():
                    break
                }
                
            }
            
        }
    }
    
    private func evaluate(_ symbol: String, _ index: Int) -> (Double, Int) {
        
        if let number = Double(symbol) {
            return (number, index)
        }
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                return (value, index)
            case .unaryOperation(let function):
                let (result, rightMostOperand) = evaluate(evaluationSequence[index+1], index+1)
                return (function(result), rightMostOperand)
            case .binaryOperation(let function):
                let (result, rightMostOperand) = evaluate(evaluationSequence[index+1], index+1)
                let (result1, rmo1) = evaluate(evaluationSequence[rightMostOperand+1], rightMostOperand+1)
                return (function(result, result1), rmo1)
            default:
                return (0, 0)
            }
        }
        return (0, 0)
    }
    
}
