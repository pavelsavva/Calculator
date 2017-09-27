//
//  ViewController.swift
//  Lab2-Calculator
//
//  Created by Student on 9/13/17.
//
//

import UIKit

class ViewController: UIViewController {
    
    //Collection of all buttons to set borders
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            for button in buttons {
                button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor.white.cgColor
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
        let (result, history) = brain.setOperand(sender.currentTitle!)
        setMainDisplayValue(result)
        currentOperationsSequenceDisplayValue = history
    }
    
    private func setMainDisplayValue(_ number: Double?) {
        if number != nil {
        resultDisplayValue = (number!.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(number!))" : "\(Double(number!))")
        } else {
            resultDisplayValue = ""
        }
    }
    
}

