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
    

    @IBOutlet weak var keyView: CustomKeyInput!
    
//
//    override func viewWillAppear(_ animated: Bool) {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
//    }
//
//    @objc func keyBoardWillShow(notification: NSNotification) {
//        print(notification)
//    }
//
//
//    @objc func keyBoardWillHide(notification: NSNotification) {
//        //handle dismiss of keyboard here
//    }
    
    //@IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var equalsButton: UIButton!
    
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
        processAction(sender.currentTitle!)
    }
    
    public func processAction(_ action: String) {
        if action == "→x" {
            keyView.setBrainController(self)
            keyView.becomeFirstResponder()
        }
        
            var variable = brain.variable
            brain.setOperand(action)
        
            if brain.currentState == .calculated {
                currentOperationsSequenceDisplayValue = ""
                resultDisplayValue = brain.getHistory().joined(separator: "") + "=" + brain.getResult()
                if variable != nil {
                    resultDisplayValue = variable! + "=" + brain.getHistory().joined(separator: "") + "=" + brain.getResult()
                }
            } else {
                resultDisplayValue = brain.getResult()
                currentOperationsSequenceDisplayValue = brain.getHistory().joined(separator: "")
                if brain.variable != nil {
                    currentOperationsSequenceDisplayValue = brain.variable! + "=" + brain.getHistory().joined(separator: "")
                }
            }
        
            if brain.currentState == .calculated || brain.currentState == .cleared {
                equalsButton.setTitle("→x", for: .normal)
            } else if brain.currentState == .precalculated || brain.currentState == .variable {
                equalsButton.setTitle("=", for: .normal)
            } else if brain.currentState == .binary || brain.currentState == .unary {
                equalsButton.setTitle("→x", for: .normal)
            }
        
        
        
    }

}

