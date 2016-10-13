//
//  SupportController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 06/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class SupportController: UITableViewController {
    
    // MARK: - View Controller Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 240
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tryOpening(DeepLinkType(rawValue: (indexPath as NSIndexPath).row)!)
    }
    
    // MARK: - Private Functions -
    
    fileprivate func tryOpening(_ type: DeepLinkType) {
        if DeepLink.schemeAvailable(type) {
            DeepLink.openSupportLink(type)
        } else {
            showNoApppInstalledAlert(type)
        }
    }
    
    fileprivate func showNoApppInstalledAlert(_ type: DeepLinkType) {
        let alert = UIAlertController(title: NSLocalizedString("Looks like \(type.name) isn't installed", comment: "No app install alert title"), message: NSLocalizedString("Would you like to install \(type.name)?", comment: "No app install alert message"), preferredStyle: .alert)
        alert.addPopoverSourceView(tableView.cellForRow(at: IndexPath(row: type.rawValue, section: 0))!)
        alert.addCancelButton()
        alert.addDefaultAction(NSLocalizedString("Install", comment: "No app install alert button")) {
            DeepLink.openItunes(type)
        }
        present(alert, animated: true) {}
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
