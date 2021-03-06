//
//  SettingsController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SafariServices
import Stripe
import SDWebImage
import MBProgressHUD

class SettingsController: UITableViewController, STPPaymentContextDelegate {
    
    @IBOutlet weak var memoryCacheSize: UILabel!
    
    var paymentContext = STPPaymentContext(apiAdapter: Payments())
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePaymentContext()
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshPaymentContext()
        updateCacheSizeView()
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - STPPaymentContextDelegate -
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print(error ?? "Payment context error")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print(error)
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case(0, 0):
            tableView.deselectRow(at: indexPath, animated: true)
            showEditProfile()
        case (0, 2):
            tableView.deselectRow(at: indexPath, animated: true)
            showPaymentMethods()
        case (0, 3):
            clearCache()
            tableView.deselectRow(at: indexPath, animated: true)
        case (1, 0):
            tableView.deselectRow(at: indexPath, animated: true)
            logout()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 1), (0, 2):
            return (!FeatureList.payments && Server.isDemo()) ? 0 : 46
        default:
            return 46
        }
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
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func showTermsOfUse() {
        let svc = SFSafariViewController(url: URL(string: "https://google.com")!)
        present(svc, animated: true, completion: nil)
    }
    
    fileprivate func showPrivacyPolicy() {
        let svc = SFSafariViewController(url: URL(string: "https://facebook.com")!)
        present(svc, animated: true, completion: nil)
    }
    
    fileprivate func showPaymentMethods() {
        if Server.currentUser?.isDemo ?? false {
            showDemoMessage()
        } else {
            paymentContext.presentPaymentMethodsViewController()
        }
    }
    
    fileprivate func showEditProfile() {
        guard let hud = MBProgressHUD.show() else { return }
        
        hud.detailsLabel.text = NSLocalizedString("Getting the profile...", comment: "Getting profile message")
        Server.getProfile
        { error, user in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let user = user {
                Router(self).showEdit(user: user)
            }
        }
    }
    
    fileprivate func logout() {
        let alert = UIAlertController(title: NSLocalizedString("Would you like to log out?", comment: "logout alert title"), preferredStyle: .alert)
        alert.add(action: NSLocalizedString("Log out", comment: "logout alert button")) {
            Server.logout()
            let _ = self.navigationController?.tabBarController?.navigationController?.popToRootViewController(animated: true)
        }
        alert.addCancelButton()
        present(alert, animated: true) {}
    }
    
    fileprivate func showDemoMessage() {
        let alert = UIAlertController(title: NSLocalizedString("Ouch!", comment:"Demo error title"), message: NSLocalizedString("You cannot select payment methods in the demo account — please login with your own account to do so", comment: "Demo error message"), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("Ok!", comment:"Demo error ok button"), style: .default)
        { action in
            if let ip = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: ip, animated: true)
            }
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - SDImageCache -
    
    fileprivate func getCacheSize() -> Double {
        let count: Double = Double(SDImageCache.shared().getSize());
        return count / (1024*1024)
    }
    
    fileprivate func clearCache() {
        SDImageCache.shared().clearDisk()
        updateCacheSizeView()
    }
    
    fileprivate func updateCacheSizeView() {
        let count = round(getCacheSize() * 10) / 10
        memoryCacheSize.text = String(format: NSLocalizedString("%.2f Mb", comment: "image cache size label"), count)
    }
}
