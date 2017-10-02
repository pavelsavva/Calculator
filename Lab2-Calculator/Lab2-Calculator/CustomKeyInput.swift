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
    public override func insertText(_ text: String){
        print(#function)
        print(text)
        print(text.characters.count)
    }
    public override func deleteBackward(){
        print(#function)
    }
    
    //UIControl
    override var canBecomeFirstResponder: Bool {return true}
}
