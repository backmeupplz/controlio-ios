//
//  SignUpViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import UITextField_Shake

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets -
    
    @IBOutlet private var textFields: [UITextField]!
    
    // MARK: - UITextFieldDelegate -
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == textFields.last {
            textField.resignFirstResponder()
            signUpTouched(textField)
        } else {
            textFields[textFields.indexOf(textField)!+1].becomeFirstResponder()
        }
        return false
    }
    
    // MARK: - Actions -
    
    @IBAction func signUpTouched(sender: AnyObject?) {
        checkTextFields()
    }
    
    @IBAction func logInTouched(sender: AnyObject) {
        Router(self).showLogIn()
    }
    
    // MARK: - Private Functions -
    
    private func checkTextFields() {
        var success = true
        for textField in textFields {
            if textField.text == "" {
                textField.shake()
                success = false
            }
        }
        if textFields[1].text != textFields[2].text {
            textFields[2].shake()
            success = false
        }
        if !success { return }
        Router(self).showMain()
    }
    
    // MARK: - Status Bar -
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
