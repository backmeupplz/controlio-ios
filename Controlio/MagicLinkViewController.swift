//
//  MagicLinkViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 05/10/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material
import UITextField_Shake

class MagicLinkViewController: UIViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var emailTextField: ErrorTextField!
    @IBOutlet weak var magicLinkButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var demoButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        if Server.isLoggedIn() {
            Router(self).showMain(animated: false)
        }
    }
    
    // MARK: - Actions -
    
    @IBAction func magicLinkTouched(_ sender: Any) {
        if emailTextField.text?.isEmail ?? false {
            emailTextField.isErrorRevealed = false
            enable(ui: false)
            Server.requestMagicLink(emailTextField.text ?? "")
            { error in
                self.enable(ui: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.snackbarController?.show(text: "Check your inbox. Magic link is on it's way!")
                }
            }
        } else {
            emailTextField.isErrorRevealed = true
            emailTextField.shake()
        }
    }
    
    @IBAction func demoTouched(_ sender: Any) {
        enable(ui: false)
        Server.login(email: "awesome@controlio.co", password: "DeepFriedPotato")
        { error in
            self.enable(ui: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.resetUI()
                Router(self).showMain()
            }
        }
    }
    
    @IBAction func loginTouched(_ sender: Any) {
        let email = emailTextField.text ?? ""
        Router(self).showLogin(email, nil)
    }
    
    // MARK: - Private functions -
    
    fileprivate func enable(ui enable: Bool) {
        [emailTextField, magicLinkButton, demoButton, loginButton]
            .forEach { $0.isEnabled = enable }
        spinner.isHidden = enable
    }
    
    fileprivate func resetUI() {
        emailTextField.text = ""
        emailTextField.isErrorRevealed = false
    }
    
    // Mark: Setting up views
    
    fileprivate func setup() {
        setupEmailTextField()
    }
    
    fileprivate func setupEmailTextField() {
        emailTextField.placeholder = "Email"
        emailTextField.detail = "Should be a valid email"
        
        emailTextField.returnKeyType = .continue
        
        emailTextField.placeholderNormalColor = Color.init(white: 1.0, alpha: 0.5)
        emailTextField.placeholderActiveColor = Color.white
        emailTextField.dividerNormalColor = Color.white
        emailTextField.dividerActiveColor = Color.white
        
        emailTextField.textColor = Color.white
        emailTextField.detailColor = Color.white
        
        emailTextField.keyboardType = .emailAddress
        
        emailTextField.delegate = self
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension MagicLinkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        magicLinkTouched(magicLinkButton)
        return false
    }
}
