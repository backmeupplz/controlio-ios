//
//  SettingsController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SafariServices

class SettingsController: UITableViewController {

    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (2, 0):
            logout()
        default:
            print(indexPath)
        }
    }
    
    // MARK: - Private functions -
    
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
    
    fileprivate func logout() {
        Server.logout()
        let _ = self.navigationController?.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        if let vc = dest as? ManagerTableViewController {
            vc.type = .show
        }
    }
}
