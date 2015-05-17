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
    
    // MARK: - IBActions -
    
    @IBAction func loginTouched(sender: AnyObject) {
        self.tryLogin()
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - General Methods -
    
    func tryLogin() {
        self.performSegueWithIdentifier("SegueToMain", sender: self)
    }
}