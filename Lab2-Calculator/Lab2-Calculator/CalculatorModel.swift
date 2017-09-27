//
//  CalculatorModel.swift
//  Lab2-Calculator
//
//  Created by Student on 9/17/17.
//
//

import Foundation

struct CalculatorBrain {
    
    private var memory: Double = 0
    private var operators = [String]()
    private var evaluators = [String]()
    
    private var currentState: State

    init() {
        currentState = .cleared
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals()
        case unaryMemoryOperation((inout Double) -> Void)
        case binaryMemoryOperation((inout Double, inout Double) -> Void)
        case clear()
        case decimal()
    }
    
    private enum State {
        case precalculated
        case calculated
        case binary
        case unary
        case cleared
        case decimal
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
        
        "MC": Operation.unaryMemoryOperation({$0 = 0}),
        
        "MR": Operation.binaryMemoryOperation({$1 = $0}),
        "MS": Operation.binaryMemoryOperation({$0 = $1}),
        "M+": Operation.binaryMemoryOperation({$0 += $1})
    ]
    
    private var binaryOperatorsPrecedence: Dictionary<String, Int> = [
        "+": 0,
        "-": 0,
        "*": 1,
        "/": 1
    ]
    
//            case .binaryMemoryOperation(let function):
//                if accumulator != nil {
//                    function(&memory, &accumulator!)
//                }
//
//            case .unaryMemoryOperation(let function):
//                function(&memory)
//
//            }
    
    mutating func setOperand(_ operand: String) -> (Double?, String) {
        
        if Int(operand) != nil {
            switch currentState {
            case .calculated:
                operators = []
                fallthrough
            case .binary,
                 .unary,
                 .cleared:
                operators.append(operand)
                currentState = .precalculated
            case .precalculated:
                if Double(operators[operators.count -  1]) != nil {
                operators[operators.count -  1] += operand
                } else {
                    operators[operators.count -  1] = operand
                }
                currentState = .precalculated
            case .decimal:
                operators[operators.count -  1] += ".\(operand)"
                currentState = .precalculated
            }
        } else if let operation = operations[operand] {
            
            switch operation {
                
            case .constant(_):
                switch currentState {
                    case .calculated:
                        operators = []
                        fallthrough
                    case .binary,
                         .unary,
                         .cleared:
                        operators.append(operand)
                        currentState = .precalculated
                    case .precalculated,
                         .decimal:
                        operators[operators.count - 1] = operand
                        currentState = .precalculated
                    }
                
            case .unaryOperation(_):
                switch currentState {
                    case .calculated:
                        operators = []
                        fallthrough
                    case .binary,
                         .cleared,
                         .unary:
                        operators.append(operand)
                        currentState = .unary
                    case .precalculated,
                         .decimal:
                        break
                }
                
            case .binaryOperation(_):
                switch currentState {
                case .precalculated:
                    operators.append(operand)
                    currentState = .binary
                case .binary:
                    operators[operators.count - 1] = operand
                    case .unary,
                     .decimal,
                     .calculated,
                     .cleared:
                    break
                }
                
            case .equals:
                break
            case .unaryMemoryOperation(_):
                break
            case .binaryMemoryOperation(_):
                break
            case .clear:
                operators = []
                currentState = .cleared
            case .decimal:
                switch currentState {
                case .calculated:
                    operators = []
                    fallthrough
                case .cleared,
                     .binary,
                     .unary:
                    operators.append("0")
                    currentState = .decimal
                case .precalculated:
                    if !operators[operators.count - 1].contains(".") && Double(operators[operators.count -  1]) != nil {
                        currentState = .decimal
                    }
                case .decimal:
                    break
                }
            }
            
        }
        
        if currentState == .precalculated {
            evaluateOperators()
            return (evaluate(evaluators[0], 0).0, operators.joined(separator: ""))
        } else {
            if currentState == .decimal {
                return (nil, operators.joined(separator: "")+".")
            } else {
            return (nil, operators.joined(separator: ""))
            }
        }
        
    }
    
    mutating private func evaluateOperators() {
        evaluators = []
        
        for operand in operators {
            if Double(operand) != nil {
                evaluators.append(operand)
            } else if let operation = operations[operand] {
                
                switch operation {
                case .constant(_):
                    evaluators.append(operand)
                case .unaryOperation(_):
                    evaluators.append(operand)
                case .binaryOperation(_):
                    if let precedence = binaryOperatorsPrecedence[operand] {
                        if precedence == 0 {
                            evaluators.insert(operand, at: 0)
                        } else if precedence == 1 {
                            evaluators.insert(operand, at: evaluators.count - 1)
                        }
                    }
                case .equals,
                     .unaryMemoryOperation(_),
                     .binaryMemoryOperation(_),
                     .clear,
                     .decimal:
                    break
                }
                
            }
        }
        
        print(evaluators)
    }
    
    private func evaluate(_ symbol: String, _ id: Int) -> (Double, Int) {
    if let number = Double(symbol) {
        return (number, id)
    }
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                return (value, id)
            case .unaryOperation(let function):
                let (result, rightMostOperand) = evaluate(evaluators[id+1], id+1)
                return (function(result), rightMostOperand)
            case .binaryOperation(let function):
                let (result, rightMostOperand) = evaluate(evaluators[id+1], id+1)
                let (result1, rmo1) = evaluate(evaluators[rightMostOperand+1], rightMostOperand+1)
                return (function(result, result1), rmo1)
            default:
                return (0, 0)
            }
        }
        return (0, 0)
    }
    
}
