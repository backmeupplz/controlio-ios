//
//  ChangePasswordViewController.swift
//  Controlio
//
//  Created by Михаил Ерохов on 26.03.17.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//


import UIKit
import Material

enum ChangePasswordViewControllerType {
    case reset
    case set
}

class ChangePasswordViewController: UIViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var repeatPasswordTextField: ErrorTextField!
    
    var token: String!
    var type = ChangePasswordViewControllerType.reset
    var parentVC: UIViewController?
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Actions -
    
    @IBAction func backTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetTouched(_ sender: Any) {
        var error = false
        repeatPasswordTextField.isErrorRevealed = false

        let length = passwordTextField.text?.characters.count ?? 0
        if (length < 8 || length > 30) {
            passwordTextField.shake()
            error = true
        }
        
        if passwordTextField.text != repeatPasswordTextField.text {
            repeatPasswordTextField.isErrorRevealed = true
            passwordTextField.shake()
            repeatPasswordTextField.shake()
            error = true
        }
        
        if !error {
            enable(ui: false)
            Server.resetPassword(token: token, password: passwordTextField.text!)
            { error in
                self.enable(ui: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.dismiss(animated: true) {
                        self.parentVC?.snackbarController?.show(text: "New password has been set")
                    }
                }
            }
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func enable(ui enable: Bool) {
        [backButton, passwordTextField, repeatPasswordTextField, resetButton]
            .forEach { $0.isEnabled = enable }
        spinner.isHidden = enable
    }
    
    // Mark: Setting up views
    
    fileprivate func setup() {
        setupBackButton()
        setupPasswordTextField()
        setupRepeatPasswordTextField()
    }
    
    fileprivate func setupBackButton() {
        backButton.setImage(Icon.close, for: .normal)
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
        passwordTextField.autocorrectionType = .no
        
        passwordTextField.keyboardType = .default
        passwordTextField.isSecureTextEntry = true
        
        passwordTextField.delegate = self
    }
    
    fileprivate func setupRepeatPasswordTextField() {
        repeatPasswordTextField.placeholder = "Repeat password"
        repeatPasswordTextField.detail = "Passwords don't match"
        
        repeatPasswordTextField.returnKeyType = .done
        
        repeatPasswordTextField.placeholderNormalColor = Color.init(white: 1.0, alpha: 0.5)
        repeatPasswordTextField.placeholderActiveColor = Color.white
        repeatPasswordTextField.dividerNormalColor = Color.white
        repeatPasswordTextField.dividerActiveColor = Color.white
        
        repeatPasswordTextField.textColor = Color.white
        repeatPasswordTextField.detailColor = Color.white
        
        repeatPasswordTextField.keyboardType = .default
        repeatPasswordTextField.isSecureTextEntry = true
        repeatPasswordTextField.autocorrectionType = .no
        
        repeatPasswordTextField.delegate = self
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields: [TextField] = [passwordTextField, repeatPasswordTextField]
        if let last = textFields.last,
            let textField = textField as? TextField {
            if textField == last {
                textField.resignFirstResponder()
            } else {
                let index = textFields.index(of: textField) ?? 0
                textFields[index + 1].becomeFirstResponder()
            }
        }
        return false
    }
}
