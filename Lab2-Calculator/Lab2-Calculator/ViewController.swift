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
    @IBOutlet weak var historyDisplay: UILabel!
    
    private var brain: CalculatorBrain = CalculatorBrain()
    private var shouldInputReset = true
    
    private var mainDisplayValue: String {
        get {
            return resultDisplay.text!
        }
        set {
            resultDisplay.text! = newValue
        }
    }
    
    private func setMainDisplayValue(_ number: Double) {
        mainDisplayValue = (number.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(number))" : "\(Double(number))")
    }
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        //Handle it somehow and not just unwrap?
        let action = sender.currentTitle ?? "Error"
        historyDisplay.text! += action
        
        if let number = Double(action) {
            if mainDisplayValue.count <= 15 {
            processNumber(number)
            }
        } else if action == "." {
                if(shouldInputReset) {
                    print("In")
                    mainDisplayValue = "0."
                } else {
                    if(!mainDisplayValue.contains(".")) {
                mainDisplayValue += action
                    }
                }
                shouldInputReset = false
        } else {
            processFunction(action)
        }
        
    }
    
    private func processNumber(_ number: Double) {
        
        if(shouldInputReset) {
            setMainDisplayValue(number)
        } else {
            setMainDisplayValue(Double(mainDisplayValue + "\(Int(number))")!)
        }
        shouldInputReset = false
        
    }
    
    private func processFunction(_ function: String) {

        if(!shouldInputReset) {
            brain.setOperand(Double(mainDisplayValue)!)
        }
        brain.performOperation(function)
        if let result = brain.result {
            setMainDisplayValue(result)
        } else {
            setMainDisplayValue(0)
        }
        
        if function == "=" {
            historyDisplay.text! = ""
        }
    
        shouldInputReset = true

        
    }
    
    
}

