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
        var success = true
        if textField.text == "" || !(textField.text?.isEmail ?? false) {
            textField.shake()
            success = false
        }
        if !success { return }
        
        enable(ui: false)
        Server.recoverPassword(textField.text!)
        { error in
            self.enable(ui: true)
            if let error = error {
                PopupNotification.show(notification: error.domain)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Success!", comment: "Recover password alert title"), message: NSLocalizedString("We have sent you a link to reset password. Please, check your inbox!", comment: "Recover password alert message"), preferredStyle: .alert)
                let ok = UIAlertAction(title: NSLocalizedString("Ok!", comment: "Recover password alert button"), style: .default)
                { action in
                    let _ = self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
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
