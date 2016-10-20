//
//  PlansController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 15/10/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MessageUI
import Stripe

enum Plan: Int {
    case free = 0
    case twenty = 1
    case fifty = 2
    case hundred = 3
}

class PlansController: UITableViewController, MFMailComposeViewControllerDelegate, STPPaymentContextDelegate {
    
    // MARK: - Outlets -
    
    var selectedPlan: Plan?
    var planToSubscribe: Plan?
    var currentPlan = Server.currentUser?.plan ?? .free {
        didSet {
            configure()
        }
    }
    
    @IBOutlet var upgradeGradients: [GradientView]!
    @IBOutlet var upgradeLabels: [UILabel]!
    @IBOutlet var yourPlanLabels: [UILabel]!
    
    // MARK: - Variables -
    
    var paymentContext = STPPaymentContext(apiAdapter: Payments())
    
    // MARK: - View Controller Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePaymentContext()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshPaymentContext()
        if let planToSubscribe = planToSubscribe {
            subsrcibe(to: planToSubscribe)
            self.planToSubscribe = nil
        }
    }
    
    // MARK: - Actions -
    
    @IBAction func planTouched(_ sender: UIButton) {
        if Server.currentUser?.isDemo ?? false {
            showDemoMessage()
        } else if sender.tag == currentPlan.rawValue {
            showAlreadyYourPlanMessage()
        } else {
            choose(plan: sender.tag)
        }
    }
    
    @IBAction func sendEmailTouched(_ sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["sales@controlio.co"])
            
            present(mail, animated: true)
        } else {
            PopupNotification.show(notification: "Please configure email in Mail app")
        }
    }
    
    // MARK: - STPPaymentContextDelegate -
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        guard let selectedPlan = selectedPlan else { return }
        if paymentContext.selectedPaymentMethod != nil {
            planToSubscribe = selectedPlan
        }
        self.selectedPlan = nil
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
        print(error)
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
        print(error)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate -
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // MARK: - Private functions -
    
    fileprivate func configurePaymentContext() {
        paymentContext.hostViewController = self
        paymentContext.delegate = self
    }
    
    fileprivate func refreshPaymentContext() {
        paymentContext = STPPaymentContext(apiAdapter: Payments())
        configurePaymentContext()
    }
    
    fileprivate func configure() {
        for number in 0...3 {
            let isCurrentPlan = number == currentPlan.rawValue
            upgradeGradients[number].isHidden = isCurrentPlan
            upgradeLabels[number].isHidden = isCurrentPlan
            upgradeLabels[number].text = number <= currentPlan.rawValue ? "Downgrade" : "Upgrade"
            yourPlanLabels[number].isHidden = !isCurrentPlan
        }
    }
    
    fileprivate func showAlreadyYourPlanMessage() {
        let alert = UIAlertController(title: "You already have this plan", message: "If you want to upgrade or downgrade your plan, please select relevant plan from the list", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok!", style: .default)
        { action in
            // do nothing
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showDemoMessage() {
        let alert = UIAlertController(title: "Ouch!", message: "You cannot select plans in the demo account — please login with your own account to purchase a plan", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok!", style: .default)
        { action in
            // do nothing
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func choose(plan: Int) {
        if paymentContext.selectedPaymentMethod == nil {
            selectedPlan = Plan(rawValue: plan)
            paymentContext.presentPaymentMethodsViewController()
        } else {
            subsrcibe(to: Plan(rawValue: plan)!)
        }
    }
    
    fileprivate func subsrcibe(to plan: Plan) {
        var message = ""
        switch plan {
        case .free:
            message = NSLocalizedString("Free", comment: "Plan name")
        case .twenty:
            message = NSLocalizedString("Twenty", comment: "Plan name")
        case .fifty:
            message = NSLocalizedString("Fifty", comment: "Plan name")
        case .hundred:
            message = NSLocalizedString("Hundred", comment: "Plan name")
        }
        message = NSLocalizedString("Would you like to switch to \"\(message)\" plan?", comment: "Alert message stub for purchase")
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: "Alert title for purchase"), message: message, preferredStyle: .alert)
        alert.addCancelButton()
        alert.addDefaultAction(NSLocalizedString("Subscribe!", comment: "Alert ok button title for purchase")) {
            print("subscribe to plan: \(plan.rawValue)")
        }
        
        present(alert, animated: true, completion: nil)
    }
}
