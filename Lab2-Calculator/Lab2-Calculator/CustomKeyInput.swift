//
//  CustomKeyInput.swift
//  Lab2-Calculator
//
//  Created by Student on 10/1/17.
//

import UIKit

class CustomKeyInput: UITextView {

    //UIKeyInput
    public override var hasText: Bool { return false }
    private var currentName = ""
    private var brainController: ViewController?
    
    public override func insertText(_ text: String){
        //print(#function)
//        if text != "\n" {
//        //currentName += text
//        } else {
//            //calculatorBrain?.calculatorState = .variable
//            self.endEditing(true)
//            //print(currentName)
//            //currentName = ""
//
//        }
        //print(text.characters.count)
        brainController!.processAction(text)
        if text == "\n" {
            self.endEditing(true)
        }
    }
    
    public override func deleteBackward(){
        //currentName.removeLast()
        brainController!.processAction("⇤")
    }
    
    public func setBrainController(_ controller: ViewController){
        brainController = controller
    }

    //UIControl
    override var canBecomeFirstResponder: Bool {return true}
}
