//
//  PlansController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 15/10/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MessageUI

enum Plan: Int {
    case free = 0
    case twenty = 1
    case fifty = 2
    case hundred = 3
}

class PlansController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - Outlets -
    
    var currentPlan = Plan.free
    
    @IBOutlet var upgradeGradients: [GradientView]!
    @IBOutlet var upgradeLabels: [UILabel]!
    @IBOutlet var yourPlanLabels: [UILabel]!
    
    // MARK: - View Controller Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Actions -
    
    @IBAction func planTouched(_ sender: UIButton) {
        print("Chose plan: \(sender.tag)")
    }
    
    @IBAction func sendEmailTouched(_ sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["paul@hackingwithswift.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            PopupNotification.showNotification("Please configure email in Mail app")
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate -
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // MARK: - Private functions -
    
    fileprivate func configure() {
        for number in 0...3 {
            let isCurrentPlan = number == currentPlan.rawValue
            upgradeGradients[number].isHidden = isCurrentPlan
            upgradeLabels[number].isHidden = isCurrentPlan
            upgradeLabels[number].text = number <= currentPlan.rawValue ? "Downgrade" : "Upgrade"
            yourPlanLabels[number].isHidden = !isCurrentPlan
        }
    }
}
