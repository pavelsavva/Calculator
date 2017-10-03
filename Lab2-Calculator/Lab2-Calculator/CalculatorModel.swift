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
    private var precleared = false
    private var lastState: State
    private var openedParentheses = 0
    public var variable: String?
   
    public var variableValues: Dictionary<String, Double> = [:]
    
    //Current state of the calculator brain
    public private (set) var currentState: State
    
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
        case parentheses()
        case openParenthesis()
        case closedParenthesis()
        case variable()
        case undo()
        case submit()
    }
    
    //States of the calculator brain
    public enum State {
        case precalculated
        case calculated
        case binary
        case unary
        case cleared
        case decimal
        case variableNameInput
        case variable
    }
    
    init() {
        currentState = .cleared
        memory = "0"
        lastState = .cleared
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
        }),
        "(": Operation.openParenthesis(),
        ")": Operation.closedParenthesis(),
        "( )": Operation.parentheses(),
        "→x": Operation.variable(),
        "⇤": Operation.undo(),
        "\n": Operation.submit()
    ]
    
    private var binaryOperatorsPrecedence: Dictionary<String, Int> = [
        "+": 1,
        "-": 1,
        "*": 2,
        "/": 2
    ]
    
    
    mutating public func setOperand(variableName: String) {
        
    }
    
    /**
     This adds the input operand to the current operator sequence.
     */
    mutating public func setOperand(_ operand: String) {
        print(operand)
        
        if currentState == .variableNameInput && operand != "⇤" && operand != "\n"{
            if inputSequence.isEmpty {
                inputSequence.append("")
            }
            inputSequence[inputSequence.count - 1] += operand
            print(inputSequence)
        } else {
        
        if Int(operand) != nil {
            
            switch currentState {
                
                case .calculated:
                    inputSequence = []
                    fallthrough
                
                case .binary,
                     .unary,
                     .cleared:
                    inputSequence.append(operand)
                    currentState = .precalculated
                
                case .precalculated:
                    if Double(inputSequence[inputSequence.count -  1]) != nil && inputSequence[inputSequence.count -  1] != "0"{
                        inputSequence[inputSequence.count -  1] += operand
                    } else {
                        inputSequence[inputSequence.count -  1] = operand
                    }
                    currentState = .precalculated
                
                case .decimal:
                    inputSequence[inputSequence.count -  1] += "\(operand)"
                    currentState = .precalculated
                
            case .variableNameInput,
                 .variable:
                break
                
            }
            
            precleared = false
            
        } else if let operation = operations[operand] {
            
            switch operation {
                
                case .constant(_):
                    switch currentState {
                    case .calculated:
                        inputSequence = []
                        fallthrough
                    case .binary,
                         .unary,
                         .cleared:
                        inputSequence.append(operand)
                        currentState = .precalculated
                    case .precalculated,
                         .decimal:
                        inputSequence[inputSequence.count - 1] = operand
                        currentState = .precalculated
                    case .variableNameInput,
                         .variable:
                        break
                    }
                
                case .unaryOperation(_):
                    switch currentState {
                    case .calculated:
                        inputSequence = []
                        fallthrough
                    case .binary,
                         .cleared,
                         .unary:
                        inputSequence.append(operand)
                        self.setOperand("(")
                        currentState = .unary
                    case .precalculated,
                         .decimal,
                         .variableNameInput,
                         .variable:
                        break
                    }
                
                case .binaryOperation(_):
                    switch currentState {
                    case .precalculated:
                        inputSequence.append(operand)
                        currentState = .binary
                    case .binary:
                        inputSequence[inputSequence.count - 1] = operand
                    case .unary,
                         .decimal,
                         .calculated,
                         .cleared,
                         .variableNameInput,
                         .variable:
                        break
                    }
                
                case .equals:
                    if currentState == .precalculated {
                        if variable != nil {
                            variableValues[variable!] = Double(getResult())
                        }
                        variable = nil
                        currentState = .calculated
                    } else if currentState == .variable {
                        currentState = .cleared
                        variable = inputSequence.removeLast()
                    }
                
                case .unaryMemoryOperation(let function):
                    function(&memory)
                
                case .binaryMemoryOperation(let function):
                    if currentState == .precalculated || currentState == .calculated {
                        function(&memory, getResult())
                    }
                
                case .memoryRestore() :
                    switch currentState {
                    case .calculated:
                        inputSequence = []
                        fallthrough
                    case .binary,
                         .unary,
                         .cleared:
                        inputSequence.append(memory)
                        currentState = .precalculated
                    case .precalculated,
                         .decimal:
                        inputSequence[inputSequence.count - 1] = memory
                        currentState = .precalculated
                    case .variableNameInput,
                         .variable:
                        break
                    }
                
                case .clear:
                    if precleared {
                        inputSequence = []
                        currentState = .cleared
                    } else if currentState != .cleared {
                        inputSequence.remove(at: inputSequence.count - 1)
                        currentState = lastState
                        precleared = true
                    }
                
                case .decimal:
                    switch currentState {
                    case .calculated:
                        inputSequence = []
                        fallthrough
                    case .cleared,
                         .binary,
                         .unary:
                        inputSequence.append("0.")
                        currentState = .decimal
                    case .precalculated:
                        if !inputSequence[inputSequence.count - 1].contains(".") && Double(inputSequence[inputSequence.count -  1]) != nil {
                            inputSequence[inputSequence.count - 1] += "."
                            currentState = .decimal
                        }
                    case .decimal,
                         .variableNameInput,
                         .variable:
                        break
                    }
                
                case .parentheses():
                    switch currentState {
                        case .calculated:
                            inputSequence = []
                            fallthrough
                        case .cleared:
                            setOperand("(")
                        case .precalculated:
                            if openedParentheses > 0 {
                                setOperand(")")
                            }
                        case .binary:
                            setOperand("(")
                        case .decimal,
                             .unary,
                             .variableNameInput,
                             .variable:
                            break
                    }
                
                case .openParenthesis:
                    inputSequence.append(operand)
                    openedParentheses += 1
                case .closedParenthesis:
                    inputSequence.append(operand)
                    openedParentheses -= 1
                case .variable:
                    currentState = .variableNameInput
                    inputSequence.append("")
            case .undo:
                if inputSequence.count != 0 {
                    inputSequence[inputSequence.count - 1].removeLast()
                    if inputSequence[inputSequence.count - 1].count == 0 {
                        inputSequence.removeLast()
                    }
                }
            case .submit():
                if variableValues[inputSequence[inputSequence.count - 1]] != nil {
                    currentState = .precalculated
                } else {
                    currentState = .variable
                }
            }
            
            switch operation {
            case .clear(),
                 .decimal(),
                 .openParenthesis(),
                 .closedParenthesis(),
                 .parentheses():
                break;
            default:
                lastState = currentState
                precleared = false
            }
            
            
        }
        
//        if let operation = operations[operand] {
//
//            switch operation {
//            case .clear():
//                if let lastOperand = inputSequence.last {
//                    inputSequence.removeLast()
//                    self.setOperand(lastOperand)
//                    print(lastOperand)
//                    precleared = true
//                }
//            default:
//                precleared = false
//            }
//
//        }
        }
    }
    
    /**
     This method return the result that the current operator sequence evaluates to.
     */
    mutating public func getResult() -> String {
        
        if currentState == .precalculated || currentState == .calculated || (currentState == .variableNameInput && variableValues[inputSequence[inputSequence.count - 1]] != nil) {
            
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
        var currentPrecedence = 0
        var lastHighPrecedenceIndex = 0
        var precedenceIndex = 0
        var indexes = Array(repeating: 0, count: 10)
        
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
                    currentPrecedence = 3
                case .binaryOperation(_):
                    if var precedence = binaryOperatorsPrecedence[operand] {
                        precedence += precedenceIndex
                        print("Operator \(operand) has precedence of \(precedence) with current precedence of \(currentPrecedence)")
                        if precedence <= currentPrecedence {
                            if precedence - precedenceIndex == 1 {
                                evaluationSequence.insert(operand, at: indexes[precedenceIndex/10])
                            } else if precedence - precedenceIndex == 2 {
                                evaluationSequence.insert(operand, at: indexes[precedenceIndex/10+1])
                            }
                            
                            currentPrecedence = precedence
                        } else if precedence > currentPrecedence {
                            indexes[precedenceIndex/10] = evaluationSequence.count - 1
                            //lastHighPrecedenceIndex = evaluationSequence.count - 1
                            evaluationSequence.insert(operand, at: evaluationSequence.count - 1)
                            currentPrecedence = precedence
                        }
                    }
                case .openParenthesis():
                    precedenceIndex += 10
                    break
                case .closedParenthesis():
                    precedenceIndex -= 10
                    break
                case .equals,
                     .unaryMemoryOperation(_),
                     .binaryMemoryOperation(_),
                     .clear,
                     .decimal,
                     .memoryRestore(),
                     .parentheses(),
                     .variable(),
                     .undo(),
                     .submit():
                    break
                }
                
            } else if variableValues[operand] != nil {
                evaluationSequence.append(operand)
            }
            
        }
        
        print(evaluationSequence)
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
        if variableValues[symbol] != nil {
            return (variableValues[symbol]!, index)
        }
        return (0, 0)
    }
    
}
