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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tryOpening(DeepLinkType(rawValue: indexPath.row)!)
    }
    
    // MARK: - Private Functions -
    
    private func tryOpening(type: DeepLinkType) {
        if DeepLink.schemeAvailable(type) {
            DeepLink.openSupportLink(type)
        } else {
            showNoApppInstalledAlert(type)
        }
    }
    
    private func showNoApppInstalledAlert(type: DeepLinkType) {
        let alert = UIAlertController(title: "Looks like \(type.name) isn't installed", message: "Would you like to install \(type.name)?", preferredStyle: .Alert)
        alert.addPopoverSourceView(tableView.cellForRowAtIndexPath(NSIndexPath(type.rawValue))!)
        alert.addCancelButton()
        alert.addDefaultAction("Install") { 
            DeepLink.openItunes(type)
        }
        presentViewController(alert, animated: true) {}
    }
}
