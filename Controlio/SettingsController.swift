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

class SettingsController: UITableViewController, STPPaymentContextDelegate {

    var paymentContext = STPPaymentContext(apiAdapter: Payments())
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePaymentContext()
        setupBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshPaymentContext()
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
        
        print(error)
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
        print(error)
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 2):
            showPaymentMethods()
        case (2, 0):
            logout()
        default:
            print(indexPath)
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
        self.present(svc, animated: true, completion: nil)
    }
    
    fileprivate func showPrivacyPolicy() {
        let svc = SFSafariViewController(url: URL(string: "https://facebook.com")!)
        self.present(svc, animated: true, completion: nil)
    }
    
    fileprivate func showPaymentMethods() {
        if Server.currentUser?.isDemo ?? false {
            showDemoMessage()
        } else {
            paymentContext.presentPaymentMethodsViewController()
        }
    }
    
    fileprivate func logout() {
        Server.logout()
        let _ = self.navigationController?.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
    
    fileprivate func showDemoMessage() {
        let alert = UIAlertController(title: "Ouch!", message: "You cannot select payment methods in the demo account — please login with your own account to do so", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok!", style: .default)
        { action in
            if let ip = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: ip, animated: true)
            }
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        if let vc = dest as? ManagerTableViewController {
            vc.type = .show
        }
    }
}
