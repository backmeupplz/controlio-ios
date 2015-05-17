//
//  ProjectListViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class ProjectListViewController: UITableViewController {
    
    // MARK: - View Controller Life Cycle -
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: false)
        addRightButton()
    }
    
    // MARK: - General Methods -
    
    func addRightButton() {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "rightButtonTouched")
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    func rightButtonTouched() {
        var alert = UIAlertController(title: "Точно выходим?", message: "Придется опять залогиниться", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Нет", style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let logoutAction: UIAlertAction = UIAlertAction(title: "Пока-пока", style: .Default) { action -> Void in
            self.logout()
        }
        alert.addAction(logoutAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func logout() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}