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
    
    @IBAction func recoverTouched(sender: AnyObject) {
        checkTextFields()
    }
    
    @IBAction func backTouched(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Private Function -
    
    private func checkTextFields() {
        var success = true
        if textField.text == "" {
            textField.shake()
            success = false
        }
        if !success { return }
        print("recover")
    }
}
