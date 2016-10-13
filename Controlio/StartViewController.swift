//
//  StartViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD

class StartViewController: UIViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet fileprivate weak var catchPhraseView: CatchPhraseView!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        catchPhraseView.labelsText = [NSLocalizedString("Controlio is a ridiculously simple status report system to track your orders and contractors", comment: "Login catch phrase 1"),
                                 NSLocalizedString("See the status of your orders like you track your parcel on mail post", comment: "Login catch phrase 2"),
                                 NSLocalizedString("Let local business inform you about your order with the speed of a screen touch!", comment: "Login catch phrase 3")]
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
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        Server.login("giraffe@controlio.co", password: "PotatoFry1984large!1")
        { error in
            hud.hide(animated: true)
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                Router(self).showMain()
            }
        }
//        let alert = UIAlertController(title: "What language do you prefer?", message: nil, preferredStyle: .actionSheet)
//        alert.addPopoverSourceView(sender)
//        alert.addCancelButton()
//        for demoAccountLanguage in DemoAccountLanguage.allCases {
//            alert.addDefaultAction(demoAccountLanguage.rawValue) {
//                self.loginDemo(demoAccountLanguage)
//            }
//        }
//        present(alert, animated: true) {}
    }
    
    // MARK: - Private Functions -
    
    fileprivate func loginDemo(_ type: DemoAccountLanguage) {
        switch type {
        case .english:
            let hud = MBProgressHUD.showAdded(to: view, animated: false)
            Server.login("giraffe@controlio.co", password: "PotatoFry1984large!1")
            { error in
                hud.hide(animated: true)
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                } else {
                    Router(self).showMain()
                }
            }
        case .russian:
            let hud = MBProgressHUD.showAdded(to: view, animated: false)
            Server.login("jaguar@controlio.co", password: "PotatoFry1984large!1")
            { error in
                hud.hide(animated: true)
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                } else {
                    Router(self).showMain()
                }
            }
        case .pizza:
            let hud = MBProgressHUD.showAdded(to: view, animated: false)
            Server.login("pizza@controlio.co", password: "PotatoFry1984large!1")
            { error in
                hud.hide(animated: true)
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                } else {
                    Router(self).showMain()
                }
            }
        case .cars:
            let hud = MBProgressHUD.showAdded(to: view, animated: false)
            Server.login("cars@controlio.co", password: "PotatoFry1984large!1")
            { error in
                hud.hide(animated: true)
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                } else {
                    Router(self).showMain()
                }
            }
        }
    }

    // MARK: - Status Bar -

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
