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
        signupTouched(signupButton)
        return false
    }
    
    // MARK: - Private functions -
    
    fileprivate func sendMagicLink() {
        
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
