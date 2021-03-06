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
import MBProgressHUD

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
            PopupNotification.show(notification: NSLocalizedString("Please configure email in Mail app", comment: "Plans VC mail app error"))
        }
    }
    
    @IBAction func redeemTouched(_ sender: AnyObject) {
        let alert = UIAlertController(title: NSLocalizedString("Redeem a coupon", comment: "Redeem alert title"), message: nil, preferredStyle:
            UIAlertControllerStyle.alert)
        
        var textField: UITextField?
        
        alert.addTextField
        { innerTextField in
            innerTextField.placeholder = NSLocalizedString("Coupon", comment: "Redeem alert textfield placeholder")
            textField = innerTextField
        }
        
        let redeem = UIAlertAction(title: NSLocalizedString("Redeem", comment: "Redem alert button"), style: .default)
        { action in
            guard let text = textField?.text, !text.isEmpty else {
                PopupNotification.show(notification: NSLocalizedString("Coupon cannot be empty", comment: "Redem alert empty error"))
                return
            }
            let coupon = text
            let hud = MBProgressHUD.showAdded(to: self.view, animated: false)
            Server.stripeRedeemCoupon(coupon: coupon)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    PopupNotification.show(notification: error.domain)
                } else {
                    PopupNotification.show(notification: NSLocalizedString("The coupon was applied to your account", comment: "Redeem alert success message"), title: NSLocalizedString("Success!", comment: "Redeem alert success title"))
                }
            }
        }
        alert.addAction(redeem)
        alert.addCancelButton()
        self.present(alert, animated: true, completion:nil)
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
        
        print(error?.localizedDescription ?? "error")
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
            upgradeLabels[number].text = number <= currentPlan.rawValue ? NSLocalizedString("Downgrade", comment: "Plans button downgrade title") : NSLocalizedString("Upgrade", comment: "Plans button upgrade title")
            yourPlanLabels[number].isHidden = !isCurrentPlan
        }
    }
    
    fileprivate func showAlreadyYourPlanMessage() {
        let alert = UIAlertController(title: NSLocalizedString("You already have this plan", comment: "Plans error title"), message: NSLocalizedString("If you want to upgrade or downgrade your plan, please select relevant plan from the list", comment: "Plans error message"), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("Ok!", comment: "Plans error button title"), style: .default)
        { action in
            // do nothing
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showDemoMessage() {
        let alert = UIAlertController(title: NSLocalizedString("Ouch!", comment: "Plans demo error title"), message: NSLocalizedString("You cannot select plans in the demo account — please login with your own account to purchase a plan", comment: "Plans demo error message"), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("Ok!", comment: "Plans demo error button title"), style: .default)
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
            message = NSLocalizedString("Five", comment: "Plan name")
        case .fifty:
            message = NSLocalizedString("Twenty", comment: "Plan name")
        case .hundred:
            message = NSLocalizedString("Fifty", comment: "Plan name")
        }
        message = String(format: NSLocalizedString("Would you like to switch to \"%@\" plan?", comment: "Alert message stub for purchase"), message)
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: "Alert title for purchase"), message: message, preferredStyle: .alert)
        alert.addCancelButton()
        alert.add(action: NSLocalizedString("Switch!", comment: "Alert ok button title for purchase")) {
            guard let hud = MBProgressHUD.show() else { return }
            Server.stripeCustomerChoose(plan: plan)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    PopupNotification.show(notification: error.domain)
                } else {
                    self.currentPlan = Server.currentUser?.plan ?? .free
                }
            }
        }
        
        present(alert, animated: true, completion: nil)
    }
}
