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
    
    @IBOutlet private weak var catchPhraseView: CatchPhraseView!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        catchPhraseView.labelsText = ["Controlio is a ridiculously simple status report system to track your orders and contractors",
                                 "See the status of your orders like you track your parcel on mail post",
                                 "Let local business inform you about your order with the speed of a screen touch!"]
        
//        Router(self).showMain(false)
    }
    
    // MARK: - Actions -
    
    @IBAction private func signupTouched(sender: AnyObject) {
        Router(self).showSignUp()
    }
    
    @IBAction private func loginTouched(sender: AnyObject) {
        Router(self).showLogIn()
    }
    
    @IBAction private func demoTouched(sender: UIButton) {
        let alert = UIAlertController(title: "What language do you speak?", message: nil, preferredStyle: .ActionSheet)
        alert.addPopoverSourceView(sender)
        alert.addCancelButton()
        for demoAccountLanguage in DemoAccountLanguage.allCases {
            alert.addDefaultAction(demoAccountLanguage.string) {
                self.loginDemo(demoAccountLanguage)
            }
        }
        presentViewController(alert, animated: true) {}
    }
    
    // MARK: - Private Functions -
    
    private func loginDemo(type: DemoAccountLanguage) {
        switch type {
        case .English:
            print("Login English")
        case .Russian:
            print("Login Russian")
        }
        Router(self).showMain()
    }
    
    // MARK: - Status Bar -
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
