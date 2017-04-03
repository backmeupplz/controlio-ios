//
//  RecoveryViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

protocol RecoveryViewControllerDelegate {
    func didRecover(email: String)
}

class RecoveryViewController: UIViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailTextField: ErrorTextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var email: String?
    var delegate: RecoveryViewControllerDelegate?
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribe()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribe()
    }
    
    // MARK: - Actions -
    
    @IBAction func backTouched(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetTouched(_ sender: Any) {
        if emailTextField.text?.isEmail ?? false {
            emailTextField.isErrorRevealed = false
            enable(ui: false)
            Server.recoverPassword(emailTextField.text ?? "")
            { error in
                self.enable(ui: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else if let email = self.emailTextField.text {
                    self.snackbarController?.show(text: "Check your inbox. Reset password link is on it's way!")
                    self.delegate?.didRecover(email: email)
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            emailTextField.isErrorRevealed = true
            emailTextField.shake()
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func enable(ui enable: Bool) {
        [backButton, emailTextField, resetButton]
            .forEach { $0.isEnabled = enable }
        spinner.isHidden = enable
    }
    
    fileprivate func resetUI() {
        emailTextField.text = ""
        emailTextField.isErrorRevealed = false
    }
    
    // Mark: Setting up views
    
    fileprivate func setup() {
        emailTextField.text = email
        setupBackButton()
        setupEmailTextField()
    }
    
    fileprivate func setupBackButton() {
        backButton.setImage(Icon.arrowBack, for: .normal)
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
    
    // MARK: - Notifications -
    
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(RecoveryViewController.login), name: NSNotification.Name(rawValue: "ShouldLogin"), object: nil)
    }
    
    func login() {
        Router(self).showMain()
    }
    
    func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension RecoveryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resetTouched(resetButton)
        return false
    }
}
