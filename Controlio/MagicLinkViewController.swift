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
    }
    
    // MARK: - Actions -
    
    @IBAction func magicLinkTouched(_ sender: Any) {
        if emailTextField.text?.isEmail ?? false {
            resetUI()
            print("should try sending email to server")
        } else {
            emailTextField.isErrorRevealed = true
            emailTextField.shake()
        }
    }
    
    @IBAction func demoTouched(_ sender: Any) {
        print("demo touched")
    }
    
    @IBAction func loginTouched(_ sender: Any) {
        Router(self).showLogin()
    }
    
    // MARK: - Private functions -
    
    fileprivate func enable(ui enable: Bool) {
        [emailTextField, magicLinkButton, demoButton, loginButton]
            .forEach { $0.isEnabled = enable }
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
