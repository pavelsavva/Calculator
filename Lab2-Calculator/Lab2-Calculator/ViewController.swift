//
//  ViewController.swift
//  Lab2-Calculator
//
//  Created by Pavel Savva on 9/13/17.
//
//

import UIKit

class ViewController: UIViewController {
    
    //Collection of buttons with grey borders
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            for button in buttons {
                button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:0.3).cgColor
            }
        }
    }

    @IBOutlet weak var resultDisplay: UILabel!
    private var resultDisplayValue: String {
        get {
            return resultDisplay.text!
        }
        set {
            resultDisplay.text! = newValue
        }
    }
    
    @IBOutlet weak var currentOperationsSequenceDisplay: UILabel!
    private var currentOperationsSequenceDisplayValue: String {
        get {
            return currentOperationsSequenceDisplay.text!
        }
        set {
            currentOperationsSequenceDisplay.text! = newValue 
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        
        brain.setOperand(sender.currentTitle!)
        if brain.calculatorState == .calculated {
            currentOperationsSequenceDisplayValue = ""
            resultDisplayValue = brain.getHistory().joined(separator: "") + "=" + brain.getResult()
        } else {
        resultDisplayValue = brain.getResult()
        currentOperationsSequenceDisplayValue = brain.getHistory().joined(separator: "")
        }
        
    }

}

