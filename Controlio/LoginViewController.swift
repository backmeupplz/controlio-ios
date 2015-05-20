//
//  LoginViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - IBActions -
    
    @IBAction func loginTouched(sender: AnyObject) {
        tryLogin()
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - General Methods -
    
    func tryLogin() {
        startServerProcess(true)
        ServerManager.sharedInstance.auth(loginTextField.text,
            password: passwordTextField.text,
            completion:{ (error: NSError?) in
                if (error == nil) {
                    self.performSegueWithIdentifier("SegueToMain", sender: self)
                }
                self.startServerProcess(false)
        })
    }
    
    func startServerProcess(start: Bool) {
        spinner.hidden = !start
        loginTextField.enabled = !start
        passwordTextField.enabled = !start
        loginButton.enabled = !start
    }
}