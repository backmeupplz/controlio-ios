//
//  LoginViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var demoLoginButton: UIButton!
    @IBOutlet weak var forgotPassButton: UIButton!
    
    // MARK: - IBActions -
    
    @IBAction func loginTouched(sender: AnyObject) {
        tryLogin()
    }
    
    @IBAction func testLogin(sender: AnyObject) {
        showTestLoginAlert()
    }
    
    @IBAction func forgotPass(sender: AnyObject) {
        resetPass()
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        var token = NSUserDefaults.standardUserDefaults().objectForKey(UDToken) as? String
        if (token != nil) {
            ServerManager.sharedInstance.token = token
            self.performSegueWithIdentifier("SegueToMainWithoutAnimation", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UITextFieldDelegate -
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - General Methods -
    
    func tryLogin() {
        tryLoginWith(loginTextField.text, password: passwordTextField.text)
    }
    
    func tryLoginWith(email: String, password: String) {
        self.startServerProcess(true)
        
        ServerManager.sharedInstance.auth(email,
            password: password,
            completion:{ (error: NSError?) in
                if (error == nil) {
                    PushNotificationsManager.sharedInstance.sendPushTokenToServer()
                    self.performSegueWithIdentifier("SegueToMain", sender: self)
                }
                self.startServerProcess(false)
        })
    }
    
    func tryResetPassWith(email: String) {
        self.startServerProcess(true)
        
        ServerManager.sharedInstance.resetPass(email, completion: { (error: NSError?) -> () in
            self.startServerProcess(false)
        })
    }
    
    func startServerProcess(start: Bool) {
        spinner.hidden = !start
        loginTextField.enabled = !start
        passwordTextField.enabled = !start
        loginButton.enabled = !start
        demoLoginButton.enabled = !start
        forgotPassButton.enabled = !start
    }
    
    func showTestLoginAlert() {
        let actionSheetController: UIAlertController = UIAlertController(title: NSLocalizedString("What language do you prefer?", comment:""), message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .Cancel) { action -> Void in
            
        }
        actionSheetController.addAction(cancelAction)
        
        let englishAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("English", comment:""), style: .Default) { action -> Void in
            self.tryLoginWith("controlio", password: "password")
        }
        actionSheetController.addAction(englishAction)
        
        let russianAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Russian", comment:""), style: .Default) { action -> Void in
            self.tryLoginWith("russian", password: "password")
        }
        actionSheetController.addAction(russianAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func resetPass() {
        let alertController: UIAlertController = UIAlertController(title: NSLocalizedString("What was your login?", comment:""), message: nil, preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .Cancel) { action -> Void in
            
        }
        alertController.addAction(cancelAction)
        
        let loginAction = UIAlertAction(title: NSLocalizedString("Reset password", comment:""), style: .Default) { (_) in
            let loginTextField = alertController.textFields![0] as! UITextField
            self.tryResetPassWith(loginTextField.text)
        }
        loginAction.enabled = false
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = NSLocalizedString("Your login", comment:"")
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                loginAction.enabled = textField.text != ""
            }
        }
        alertController.addAction(loginAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}