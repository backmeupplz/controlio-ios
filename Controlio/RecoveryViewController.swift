//
//  RecoveryViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class RecoveryViewController: UIViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var textField: RoundedBorderedTextField!
    
    // MARK: - Actions -
    
    @IBAction func recoverTouched(_ sender: AnyObject) {
        checkTextFields()
    }
    
    @IBAction func backTouched(_ sender: AnyObject) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Function -
    
    fileprivate func checkTextFields() {
        var success = true
        if textField.text == "" {
            textField.shake()
            success = false
        }
        if !success { return }
        print("recover")
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
