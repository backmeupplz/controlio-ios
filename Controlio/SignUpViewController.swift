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
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
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
                PopupNotification.showNotification("All fields should be filled");
                textField.shake()
                success = false
            }
        }
        if textFields[1].text != textFields[2].text {
            PopupNotification.showNotification("Passwords don't match");
            textFields[2].shake()
            success = false
        }
        if !success { return }
        
        enableUI(false)
        Server.sharedManager.signup(textFields[0].text!,
                                    password: textFields[1].text!)
        { error in
            self.enableUI(true)
            if let error = error {
                PopupNotification.showNotification(error)
            } else {
                Router(self).showMain()
            }
        }
    }
    
    private func enableUI(enable: Bool) {
        spinner.hidden = enable
        for textField in textFields {
            textField.enabled = enable
        }
        for button in buttons {
            button.enabled = enable
        }
    }
    
    // MARK: - Status Bar -
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
