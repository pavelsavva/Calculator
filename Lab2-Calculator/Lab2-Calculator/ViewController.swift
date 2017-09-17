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
    
    private var clearPressed = false
    private var memory: String?
    private var brain: CalculatorBrain = CalculatorBrain()
    
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
        
        if let number = Double(action) {
            processNumber(number)
        } else {
            processFunction(action)
        }
    }
    
    private func processNumber(_ number: Double) {
        clearPressed = false
        
        if(mainDisplayValue == "0") {
            setMainDisplayValue(number)
        } else {
            setMainDisplayValue(Double(mainDisplayValue + "\(number)")!)
        }
    }
    
    private func processFunction(_ function: String) {
        
        brain.setOperand(Double(mainDisplayValue)!)
        brain.performOperation(function)
        
        if let result = brain.result {
            setMainDisplayValue(result)
        } else {
            setMainDisplayValue(0)
        }
//        
//        if(function != "C") {
//            clearPressed = false
//        }
//        
//        switch(function) {
//            
//        case ".":
//            if(!mainDesplayValue.contains(".")) {
//                mainDesplayValue += function
//            }
//        case "π":
//            setMainDisplayValue(Double.pi)
//        case "e":
//            setMainDisplayValue(2.7182818284590)
//        case "C":
//            mainDesplayValue = "0"
//            if !clearPressed {
//                clearPressed = true
//            } else {
//                print("Stack cleared!")
//                clearPressed = false
//            }
//        case "MR":
//            if memory != nil {
//                mainDesplayValue = memory!
//            }
//        case "MC":
//            memory = nil
//        case "MS":
//            memory = mainDesplayValue
//        case "M+":
//            if memory != nil {
//                memory = "\(Double(memory!)! + Double(mainDesplayValue)!)"
//            }
//        default:
//            break
//        }
        
    }
    
    
}

