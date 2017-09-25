//
//  ViewController.swift
//  Lab2-Calculator
//
//  Created by Student on 9/13/17.
//
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultDisplay: UILabel!
    private var resultDisplayValue: String {
        get {
            return resultDisplay.text!
        }
        set {
            resultDisplay.text! = newValue
        }
    }
    
    @IBOutlet weak var historyDisplay: UILabel!
    
    //Collection of all buttons to set borders
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            for button in buttons {
                button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    private var shouldInputReset = true
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        
        let action = sender.currentTitle!
        
        if let number = Int(action) {
            processNumber(number)
        } else if action == "." {
            processDecimalPoint()
        } else {
            processFunction(action)
        }
        
    }
    
    private func processDecimalPoint() {
        
        if shouldInputReset {
            resultDisplayValue = "0."
        } else if !resultDisplayValue.contains(".") {
            resultDisplayValue += "."
        }
        shouldInputReset = false
        
    }
    
    private func processNumber(_ number: Int) {
        
        if shouldInputReset {
            setMainDisplayValue(Double(number))
        } else if resultDisplayValue.count <= 15 {
            setMainDisplayValue(Double(resultDisplayValue + "\(number)")!)
        }
        
        shouldInputReset = false
        
    }
    
    private func processFunction(_ function: String) {
        
        if(shouldInputReset) {
            brain.setOperand(Double(resultDisplayValue)!, false)
        } else {
            brain.setOperand(Double(resultDisplayValue)!, true)
        }
        
        brain.performOperation(function)
        
        if let result = brain.result {
            setMainDisplayValue(result)
            shouldInputReset = false
        } else {
            shouldInputReset = true
        }
        
        historyDisplay.text! = brain.getHistory()
        
        
    }
    
    private func setMainDisplayValue(_ number: Double) {
        resultDisplayValue = (number.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(number))" : "\(Double(number))")
    }
    
}

