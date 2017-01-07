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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var recoverButton: RoundedShadowedButton!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Actions -
    
    @IBAction func recoverTouched(_ sender: AnyObject) {
        checkTextFields()
    }
    
    @IBAction func backTouched(_ sender: AnyObject) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Function -
    
    fileprivate func checkTextFields() {
    }
    
    fileprivate func enable(ui: Bool) {
        textField.isEnabled = ui
        spinner.isHidden = ui
        recoverButton.isEnabled = ui
        backButton.isEnabled = ui
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
