//
//  MagicLinkViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 05/10/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class MagicLinkViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var emailTextField: RoundedBorderedTextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var magicLinkButton: RoundedShadowedButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    // MARK: - Actions -

    @IBAction func magicLinkTouched(_ sender: AnyObject) {
        sendMagicLink()
    }
    
    @IBAction func loginTouched(_ sender: AnyObject) {
        Router(self).showLogIn()
    }
    
    @IBAction func signupTouched(_ sender: AnyObject) {
        Router(self).showSignUp()
    }
    
    // MARK: - UITextFieldDelegate -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        magicLinkTouched(magicLinkButton)
        return false
    }
    
    // MARK: - Private functions -
    
    fileprivate func sendMagicLink() {
        var success = true
        if emailTextField.text == "" || !(emailTextField.text?.isEmail ?? false) {
            emailTextField.shake()
            success = false
        }
        if !success { return }
        
        enable(ui: false)
        
        Server.requestMagicLink(emailTextField.text!)
        { error in
            self.enable(ui: true)
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                let alert = UIAlertController(title: "Success!", message: "We have sent you a magic link to login. Please, check your inbox!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok!", style: .default)
                { action in
                    // Do nothing
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func enable(ui: Bool) {
        emailTextField.isEnabled = ui
        spinner.isHidden = ui
        magicLinkButton.isEnabled = ui
        loginButton.isEnabled = ui
        signupButton.isEnabled = ui
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
