//
//  SettingsController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {

    // MARK: - View Controller Life Cycle -
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (4, 0):
            logout()
        default:
            print(indexPath)
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func logout() {
        Server.currentUser = nil
        let _ = self.navigationController?.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
}
