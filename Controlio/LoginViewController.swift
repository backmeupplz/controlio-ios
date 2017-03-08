//
//  SignUpViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material
import UITextField_Shake

enum LoginViewControllerState: Int {
    case signup = 0
    case signin = 1
}

class LoginViewController: UIViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var screenPicker: UISegmentedControl!
    @IBOutlet weak var emailTextField: ErrorTextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var repeatPasswordTextField: ErrorTextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var passwordToRepeatPassword: NSLayoutConstraint!
    @IBOutlet weak var passwordToSignupButton: NSLayoutConstraint!
    
    // MARK: - Variables -
    
    var state = LoginViewControllerState.signup
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Actions -
    
    @IBAction func backTouched(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func screenPickerChanged(_ sender: UISegmentedControl) {
        state = LoginViewControllerState(rawValue: sender.selectedSegmentIndex)!
        setup(for: state)
    }
    
    @IBAction func forgotPasswordTouched(_ sender: AnyObject) {
        Router(self).showRecovery()
    }
    
    @IBAction func signupTouched(_ sender: Any) {
        var error = false
        
        let emailLength = emailTextField.text?.characters.count ?? 0
        if !(emailTextField.text?.isEmail ?? false && emailLength < 100) {
            emailTextField.isErrorRevealed = true
            emailTextField.shake()
            error = true
        } else {
            emailTextField.isErrorRevealed = false
        }
        let length = passwordTextField.text?.characters.count ?? 0
        if (length < 8 || length > 30) {
            passwordTextField.shake()
            error = true
        }
        if passwordTextField.text != repeatPasswordTextField.text && state == .signup {
            repeatPasswordTextField.isErrorRevealed = true
            passwordTextField.shake()
            repeatPasswordTextField.shake()
            error = true
        } else {
            repeatPasswordTextField.isErrorRevealed = false
        }
        
        if !error {
            enable(ui: false)
            if state == .signup {
                Server.signup(email: emailTextField.text!, password: passwordTextField.text!)
                { error in
                    self.enable(ui: true)
                    if let error = error {
                        self.snackbarController?.show(error: error.domain)
                    } else {
                        self.resetUI()
                        Router(self).showMain()
                    }
                }
            } else {
                Server.login(email: emailTextField.text!, password: passwordTextField.text!)
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
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func enable(ui enable: Bool) {
        [backButton, screenPicker, emailTextField, passwordTextField, repeatPasswordTextField, signupButton, forgotPasswordButton]
            .forEach { $0.isEnabled = enable }
        spinner.isHidden = enable
    }
    
    fileprivate func resetUI() {
        emailTextField.text = ""
        emailTextField.isErrorRevealed = false
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
        repeatPasswordTextField.isErrorRevealed = false
    }
    
    fileprivate func setup(for state: LoginViewControllerState) {
        repeatPasswordTextField.isHidden = state == .signin
        
        passwordToSignupButton.priority = state == .signin ? 750 : 500
        passwordToRepeatPassword.priority = state == .signin ? 500 : 750
        view.layoutIfNeeded()
        
        signupButton.setTitle(state == .signin ? "Sign in" : "Sign up", for: .normal)
    }
    
    // Mark: Setting up views
    
    fileprivate func setup() {
        setupBackButton()
        setupEmailTextField()
        setupPasswordTextField()
        setupRepeatPasswordTextField()
    }
    
    fileprivate func setupBackButton() {
        backButton.setImage(Icon.arrowBack, for: .normal)
    }
    
    fileprivate func setupEmailTextField() {
        emailTextField.placeholder = "Email"
        emailTextField.detail = "Should be a valid email"
        
        emailTextField.returnKeyType = .next
        
        emailTextField.placeholderNormalColor = Color.init(white: 1.0, alpha: 0.5)
        emailTextField.placeholderActiveColor = Color.white
        emailTextField.dividerNormalColor = Color.white
        emailTextField.dividerActiveColor = Color.white
        
        emailTextField.textColor = Color.white
        emailTextField.detailColor = Color.white
        
        emailTextField.keyboardType = .emailAddress
        
        emailTextField.delegate = self
    }
    
    fileprivate func setupPasswordTextField() {
        passwordTextField.placeholder = "Password"
        passwordTextField.detail = "Should be between 8 and 30 characters"
        
        passwordTextField.returnKeyType = .next
        
        passwordTextField.placeholderNormalColor = Color.init(white: 1.0, alpha: 0.5)
        passwordTextField.placeholderActiveColor = Color.white
        passwordTextField.dividerNormalColor = Color.white
        passwordTextField.dividerActiveColor = Color.white
        
        passwordTextField.textColor = Color.white
        passwordTextField.detailColor = Color.white
        
        passwordTextField.keyboardType = .default
        passwordTextField.isSecureTextEntry = true
        
        passwordTextField.delegate = self
    }
    
    fileprivate func setupRepeatPasswordTextField() {
        repeatPasswordTextField.placeholder = "Repeat password"
        repeatPasswordTextField.detail = "Passwords don't match"
        
        repeatPasswordTextField.returnKeyType = .continue
        
        repeatPasswordTextField.placeholderNormalColor = Color.init(white: 1.0, alpha: 0.5)
        repeatPasswordTextField.placeholderActiveColor = Color.white
        repeatPasswordTextField.dividerNormalColor = Color.white
        repeatPasswordTextField.dividerActiveColor = Color.white
        
        repeatPasswordTextField.textColor = Color.white
        repeatPasswordTextField.detailColor = Color.white
        
        repeatPasswordTextField.keyboardType = .default
        repeatPasswordTextField.isSecureTextEntry = true
        
        repeatPasswordTextField.delegate = self
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields: [TextField] = [emailTextField, passwordTextField, repeatPasswordTextField]
        if let last = textFields.last,
            let textField = textField as? TextField {
            if textField == last {
                textField.resignFirstResponder()
                signupTouched(signupButton)
            } else {
                let index = textFields.index(of: textField) ?? 0
                textFields[index + 1].becomeFirstResponder()
            }
        }
        return false
    }
}
