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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribe()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribe()
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
                    self.snackbarController?.show(text: NSLocalizedString("Check your inbox. Magic link is on it's way!", comment: "magic link request success message"))
                }
            }
        } else {
            emailTextField.isErrorRevealed = true
            emailTextField.shake()
        }
    }
    
    @IBAction func demoTouched(_ sender: Any) {
        enable(ui: false)
        Server.login(email: NSLocalizedString("awesome@controlio.co", comment: "demo user login"), password: NSLocalizedString("DeepFriedPotato", comment: "demo user password"))
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
        Router(self).showLogin(email: emailTextField.text)
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
        emailTextField.placeholder = NSLocalizedString("Email", comment: "email textfield placeholder")
        emailTextField.detail = NSLocalizedString("Should be a valid email", comment: "email textfield comment line")
        
        emailTextField.returnKeyType = .done
        
        emailTextField.placeholderNormalColor = Color.init(white: 1.0, alpha: 0.5)
        emailTextField.placeholderActiveColor = Color.white
        emailTextField.dividerNormalColor = Color.white
        emailTextField.dividerActiveColor = Color.white
        
        emailTextField.textColor = Color.white
        emailTextField.detailColor = Color.white
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        
        emailTextField.delegate = self
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Notifications -
    
    func subscribe() {
        subscribe(to: [
            .shouldLogin: #selector(MagicLinkViewController.login)
        ])
    }
    
    func login() {
        Router(self).showMain()
    }
}

extension MagicLinkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
