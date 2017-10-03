//
//  CalculatorModel.swift
//  Lab2-Calculator
//
//  Created by Pavel Savva on 9/17/17.
//
//

import Foundation

struct CalculatorBrain {
    
    //Current memory value
    private var memory: String
    //Sequence of operators as they were passed to the brain
    private var inputSequence = [String]()
    //Sequence of operators that can be evaluated based on operator precedence
    private var evaluatableSequence = [String]()
    //Flag that indicates that the last function called was Clear
    private var precleared = false
    //The state last state before the current operation get processed that was not calculated or precalculated
    private var lastState: State
    //The number of currently opened parentheses in the input
    private var openedParentheses = 0
    //Name on the variable that is currently being assigned, nil if none
    public var variableBeingAssigned: String?
    //Dictionary of variables and their values
    //Not used outside of the CalculatorBrain, but public to satisfy the lab requirements
    public var variableValues: Dictionary<String, Double> = [:]
    //Current state of the calculator brain
    public private (set) var currentState: State
    
    private var states = [State]()
    
    //States of the calculator brain
    public enum State {
        case precalculated
        case calculated
        case binary
        case unary
        case cleared
        case decimal
        case variableNameInput
        case newVariable
    }
    
    private enum ArithmeticOperation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
    }
    
    private enum MemoryOperation {
        case unaryMemoryOperation((inout String) -> Void)
        case binaryMemoryOperation((inout String, String) -> Void)
        case memoryRestore()
    }
    
    private enum InputOperation {
        case equals()
        case clear()
        
        case decimal()
        
        case parentheses()
        case openParenthesis()
        case closedParenthesis()
        
        case variable()
        case submit()
        
        case undo()
    }
    
    private var operations: Dictionary<String, ArithmeticOperation> = [
        "+": ArithmeticOperation.binaryOperation({$0 + $1}),
        "-": ArithmeticOperation.binaryOperation({$0 - $1}),
        "*": ArithmeticOperation.binaryOperation({$0 * $1}),
        "/": ArithmeticOperation.binaryOperation({$0 / $1}),
        
        "π": ArithmeticOperation.constant(Double.pi),
        "e": ArithmeticOperation.constant(M_E),
        
        "√": ArithmeticOperation.unaryOperation({sqrt($0)}),
        "cos": ArithmeticOperation.unaryOperation({cos($0)}),
        "sin": ArithmeticOperation.unaryOperation({sin($0)}),
        "tan": ArithmeticOperation.unaryOperation({tan($0)}),
        "cot": ArithmeticOperation.unaryOperation({1/tan($0)}),
        "±": ArithmeticOperation.unaryOperation({-$0}),
        "ln": ArithmeticOperation.unaryOperation({log($0)}),
        ]
    
    private var memoryOperations: Dictionary<String, MemoryOperation> = [
        "MC": MemoryOperation.unaryMemoryOperation({$0 = "0"}),
        "MR": MemoryOperation.memoryRestore(),
        "MS": MemoryOperation.binaryMemoryOperation({$0 = $1}),
        "M+": MemoryOperation.binaryMemoryOperation({
            let result = Double($0)! + Double($1)!
            $0 = result.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(result))" : "\(Double(result))"
        })
    ]
    
    private var inputOperations: Dictionary<String, InputOperation> = [
        "=": InputOperation.equals(),
        "C": InputOperation.clear(),
        ".": InputOperation.decimal(),
        
        "(": InputOperation.openParenthesis(),
        ")": InputOperation.closedParenthesis(),
        "( )": InputOperation.parentheses(),
        "→x": InputOperation.variable(),
        "⇤": InputOperation.undo(),
        "\n": InputOperation.submit()
    ]
    
    private var binaryOperatorsPrecedence: Dictionary<String, Int> = [
        "+": 1,
        "-": 1,
        "*": 2,
        "/": 2
    ]
    
    //Default initializer
    init() {
        currentState = .cleared
        memory = "0"
        lastState = .cleared
    }
    
    //Note: This method only exists to satisfy the lab API requirements.
    mutating public func setOperand(variableName: String) {
        currentState = .variableNameInput
        setOperand(variableName)
        setOperand("\n")
        states.append(currentState)
    }
    
    //This adds the input operand to the current operator sequence.
    mutating public func setOperand(_ operand: String) {
        
        if currentState == .variableNameInput && operand != "⇤" && operand != "\n"{
            if inputSequence.isEmpty {
                inputSequence.append("")
            }
            inputSequence[inputSequence.count - 1] += operand
        } else {
            
            if Int(operand) != nil {
                processIntegerInput(operand)
                
            } else if let operation = operations[operand] {
                switch operation {
                case .constant(_):
                    processConstantInput(operand)
                case .unaryOperation(_):
                    processUnaryFunctionInput(operand)
                case .binaryOperation(_):
                    processBinaryFunctionInput(operand)
                }
                
                if currentState != .precalculated && currentState != .calculated {
                    lastState = currentState
                }
                precleared = false
                
            } else if let operation = memoryOperations[operand] {
                switch operation {
                case .unaryMemoryOperation(let function):
                    function(&memory)
                case .binaryMemoryOperation(let function):
                    if currentState == .precalculated || currentState == .calculated {
                        function(&memory, getResult())
                    }
                case .memoryRestore() :
                    processMemoryRestoreInput(operand)
                }
                
            } else if let operation = inputOperations[operand] {
                switch operation {
                case .equals:
                    processEqualsFunctionInput(operand)
                case .clear:
                    processClearFunctionInput(operand)
                case .decimal:
                    processDecimalInput(operand)
                case .parentheses():
                    processParenthesesInput(operand)
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
                    processUndo(operand)
                case .submit():
                    processSubmit(operand)
                }
            }
            
        }
        
        if currentState == .precalculated || (!states.isEmpty && states[states.count - 1] != currentState) {
            states.append(currentState)
        }
        
    }
    
    private mutating func processIntegerInput(_ operand: String) {
        
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
             .newVariable:
            break
            
        }
        
        precleared = false
        
    }
    
    private mutating func processConstantInput(_ operand: String) {
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
             .newVariable:
            break
        }
    }
    
    private mutating func processUnaryFunctionInput(_ operand: String) {
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
             .newVariable:
            break
        }
    }
    
    private mutating func processBinaryFunctionInput(_ operand: String) {
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
             .newVariable:
            break
        }
    }
    
    private mutating func processMemoryRestoreInput(_ operand: String) {
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
             .newVariable:
            break
        }
    }
    
    private mutating func processEqualsFunctionInput(_ operand: String) {
        if currentState == .precalculated {
            if variableBeingAssigned != nil {
                variableValues[variableBeingAssigned!] = Double(getResult())
            }
            variableBeingAssigned = nil
            currentState = .calculated
        } else if currentState == .newVariable {
            currentState = .cleared
            variableBeingAssigned = inputSequence.removeLast()
        }
    }
    
    private mutating func processClearFunctionInput(_ operand: String) {
        if precleared {
            inputSequence = []
            currentState = .cleared
            variableBeingAssigned = nil
        } else if currentState != .cleared {
            inputSequence.remove(at: inputSequence.count - 1)
            if !inputSequence.isEmpty {
                currentState = lastState
            } else {
                currentState = .cleared
            }
        }
        precleared = true
    }
    
    private mutating func processDecimalInput(_ operand: String) {
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
             .newVariable:
            break
        }
    }
    
    private mutating func processParenthesesInput(_ operand: String) {
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
             .newVariable:
            break
        }
    }
    
    private mutating func processUndo(_ operand: String) {
        if states.count > 1 {
            states.removeLast()
            currentState = states.removeLast()
        }
        if inputSequence.count != 0 {
            inputSequence[inputSequence.count - 1].removeLast()
            if inputSequence[inputSequence.count - 1].count == 0 {
                inputSequence.removeLast()
                if inputSequence.isEmpty {
                    currentState = .cleared
                    states = [currentState]
                }
            }
        }
    }
    
    private mutating func processSubmit(_ operand: String) {
        if variableValues[inputSequence[inputSequence.count - 1]] != nil {
            currentState = .precalculated
        } else {
            currentState = .newVariable
        }
    }

    /**
     This method return the result that the current operator sequence evaluates to.
     */
    mutating public func getResult() -> String {

        if currentState == .precalculated || currentState == .calculated || (currentState == .variableNameInput && variableValues[inputSequence[inputSequence.count - 1]] != nil) {
            
            createEvaluatableSequence()
            
            let result = evaluate(evaluatableSequence.first!, 0)
            
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
    
    mutating private func createEvaluatableSequence() {
        var currentPrecedence = 0
        var precedenceIndex = 0
        var indexes = Array(repeating: 0, count: 10)
        
        evaluatableSequence = []
        
        for operand in inputSequence {
            
            if Double(operand) != nil {
                
                evaluatableSequence.append(operand)
                
            } else if let operation = operations[operand] {
                
                switch operation {
                case .constant(_):
                    evaluatableSequence.append(operand)
                case .unaryOperation(_):
                    evaluatableSequence.append(operand)
                    indexes[precedenceIndex/10 + 1] = evaluatableSequence.count
                    currentPrecedence = 1 + precedenceIndex + 10
                case .binaryOperation(_):
                    if var precedence = binaryOperatorsPrecedence[operand] {
                        precedence += precedenceIndex
                        if precedence <= currentPrecedence {
                            if precedence - precedenceIndex == 1 {
                                evaluatableSequence.insert(operand, at: indexes[precedenceIndex/10])
                            } else if precedence - precedenceIndex == 2 {
                                evaluatableSequence.insert(operand, at: indexes[precedenceIndex/10+1]+1)
                            }
                            
                            currentPrecedence = precedence
                        } else if precedence > currentPrecedence {
                            indexes[precedenceIndex/10] = evaluatableSequence.count - 1
                            evaluatableSequence.insert(operand, at: evaluatableSequence.count - 1)
                            currentPrecedence = precedence
                        }
                    }
                }
                
            } else if let operation = inputOperations[operand] {
                
                switch operation {
                case .openParenthesis():
                    precedenceIndex += 10
                    break
                case .closedParenthesis():
                    precedenceIndex -= 10
                    break
                default:
                    break
                }
                
            } else if variableValues[operand] != nil {
                evaluatableSequence.append(operand)
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
                let (result, rightMostOperand) = evaluate(evaluatableSequence[index+1], index+1)
                return (function(result), rightMostOperand)
            case .binaryOperation(let function):
                let (result, rightMostOperand) = evaluate(evaluatableSequence[index+1], index+1)
                let (result1, rmo1) = evaluate(evaluatableSequence[rightMostOperand+1], rightMostOperand+1)
                return (function(result, result1), rmo1)
            }
        }
        if variableValues[symbol] != nil {
            return (variableValues[symbol]!, index)
        }
        return (0, 0)
    }
    
}
