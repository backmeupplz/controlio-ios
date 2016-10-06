//
//  StartViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SnapKit

class StartViewController: UIViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet fileprivate weak var catchPhraseView: CatchPhraseView!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        catchPhraseView.labelsText = ["Controlio is a ridiculously simple status report system to track your orders and contractors",
                                 "See the status of your orders like you track your parcel on mail post",
                                 "Let local business inform you about your order with the speed of a screen touch!"]
        if Server.isLoggedIn() {
            Router(self).showMain(false)
        }
    }
    
    // MARK: - Actions -
    
    @IBAction fileprivate func signupTouched(_ sender: AnyObject) {
        Router(self).showMagicLink()
    }
    
    @IBAction fileprivate func loginTouched(_ sender: AnyObject) {
        Router(self).showLogIn()
    }
    
    @IBAction fileprivate func demoTouched(_ sender: UIButton) {
        let alert = UIAlertController(title: "What language do you speak?", message: nil, preferredStyle: .actionSheet)
        alert.addPopoverSourceView(sender)
        alert.addCancelButton()
        for demoAccountLanguage in DemoAccountLanguage.allCases {
            alert.addDefaultAction(demoAccountLanguage.rawValue) {
                self.loginDemo(demoAccountLanguage)
            }
        }
        present(alert, animated: true) {}
    }
    
    // MARK: - Private Functions -
    
    fileprivate func loginDemo(_ type: DemoAccountLanguage) {
        switch type {
        case .english:
            print("Login English")
        case .russian:
            print("Login Russian")
        }
        Router(self).showMain()
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
