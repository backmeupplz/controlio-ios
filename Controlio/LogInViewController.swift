//
//  LogInViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets -
    
    @IBOutlet private var textFields: [UITextField]!
    
    // MARK: - UITextFieldDelegate -
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == textFields.last {
            textField.resignFirstResponder()
            logInTouched(textField)
        } else {
            textFields[textFields.indexOf(textField)!+1].becomeFirstResponder()
        }
        return false
    }
    
    // MARK: - Actions -
    
    @IBAction func logInTouched(sender: AnyObject) {
        checkTextFields()
    }
    
    @IBAction func forgotPasswordTouched(sender: AnyObject) {
        Router(self).showRecovery()
    }
    
    @IBAction func signUpTouched(sender: AnyObject) {
        Router(self).showSignUp()
    }
    
    @IBAction func demoTouched(sender: UIButton) {
        let alert = UIAlertController(title: "What language do you speak?", message: nil, preferredStyle: .ActionSheet)
        alert.addPopoverSourceView(sender)
        alert.addCancelButton()
        for demoAccountLanguage in DemoAccountLanguage.allCases {
            alert.addDefaultAction(demoAccountLanguage.string) {
                self.loginDemo(demoAccountLanguage)
            }
        }
        presentViewController(alert, animated: true) {}
    }
    
    // MARK: - Private Function -
    
    private func loginDemo(type: DemoAccountLanguage) {
        switch type {
        case .English:
            print("Login English")
        case .Russian:
            print("Login Russian")
        }
        Router(self).showMain()
    }
    
    private func checkTextFields() {
        var success = true
        for textField in textFields {
            if textField.text == "" {
                textField.shake()
                success = false
            }
        }
        if !success { return }
        Router(self).showMain()
    }
}
