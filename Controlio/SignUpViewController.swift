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
    
    @IBOutlet fileprivate var textFields: [UITextField]!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - UITextFieldDelegate -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFields.last {
            textField.resignFirstResponder()
            signUpTouched(textField)
        } else {
            textFields[textFields.index(of: textField)!+1].becomeFirstResponder()
        }
        return false
    }
    
    // MARK: - Actions -
    
    @IBAction func backTouched(_ sender: AnyObject) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpTouched(_ sender: AnyObject?) {
        checkTextFields()
    }
    
    @IBAction func logInTouched(_ sender: AnyObject) {
        Router(self).showLogIn()
    }
    
    @IBAction func forgotPasswordTouched(_ sender: AnyObject) {
        Router(self).showRecovery()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func checkTextFields() {
        var success = true
        for textField in textFields {
            if textField.text == "" {
                PopupNotification.showNotification(NSLocalizedString("All fields should be filled", comment: "Error"));
                textField.shake()
                success = false
            }
        }
        if textFields[1].text != textFields[2].text {
            PopupNotification.showNotification(NSLocalizedString("Passwords don't match", comment: "Error"));
            textFields[2].shake()
            success = false
        }
        if !success { return }
        
        enableUI(false)
        Server.signup(email: textFields[0].text!, password: textFields[1].text!)
        { error in
            self.enableUI(true)
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                Router(self).showMain()
            }
        }
    }
    
    fileprivate func enableUI(_ enable: Bool) {
        spinner.isHidden = enable
        for textField in textFields {
            textField.isEnabled = enable
        }
        for button in buttons {
            button.isEnabled = enable
        }
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
