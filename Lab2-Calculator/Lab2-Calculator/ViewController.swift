//
//  ViewController.swift
//  Lab2-Calculator
//
//  Created by Pavel Savva on 9/13/17.
//
//

import UIKit




class ViewController: UIViewController {
    
    //Add left swipe recognizer
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(undo))
        
        leftSwipeRecognizer.direction = .left
        
        view.addGestureRecognizer(leftSwipeRecognizer)
        
    }
    
    //Collection of buttons with grey borders
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            for button in buttons {
                button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:0.3).cgColor
            }
        }
    }
    
    //Process left swipe as undo
    @objc func undo(sender:UISwipeGestureRecognizer) {
        processAction("⇤")
    }
    
    //Hidden view that wil show the standard keyboard. Used to process keys pressed in the ViewController instead of displaying them in a UITextView.
    @IBOutlet weak var keyView: CustomKeyInput!
    
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
       
        //Save the name of the variable to display in the result window, before the brain changes it
        let variableBeingAssigned = brain.variableBeingAssigned
        
        brain.setOperand(action)
        
        resultDisplayValue = brain.getResult()
        
        currentOperationsSequenceDisplayValue = brain.getHistory().joined(separator: "")
        
        if brain.variableBeingAssigned != nil {
            currentOperationsSequenceDisplayValue = brain.variableBeingAssigned! + "=" + brain.getHistory().joined(separator: "")
        }
        
        switch brain.currentState {
        case .variableNameInput:
            //Open the default iOS keyboard
            keyView.setBrainController(self)
            keyView.becomeFirstResponder()
        case .precalculated,
             .newVariable:
            //Variable cannot be created or inserted
            equalsButton.setTitle("=", for: .normal)
        case .calculated:
            currentOperationsSequenceDisplayValue = ""
            
            //Display the assignment result or ignore if no assignment was made
            if variableBeingAssigned != nil {
                resultDisplayValue = variableBeingAssigned! + "="
            } else {
                resultDisplayValue = ""
            }
            
            if brain.getHistory().count != 1 {
                resultDisplayValue += brain.getHistory().joined(separator: "") + "="
            }
            
            resultDisplayValue += brain.getResult()
            
            fallthrough
            
        case .cleared,
             .binary,
             .unary:
            //Variable can be created or inserted
            equalsButton.setTitle("→x", for: .normal)
        default:
            break
        }
    }
    
}

