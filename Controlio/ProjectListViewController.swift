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
    
    // MARK: - Variables -
    
    var tableData = [ProjectObject]() {
        didSet {
            tableView.reloadData()
            tableView.layoutSubviews()
            refreshControl?.endRefreshing()
        }
    }
    
    var noMoreData: Bool = false
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        configureTableView()
        setupRefreshControl()
        updateData()
        checkForProjectToShow()
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (!noMoreData && isLastCellAtIndexPath(indexPath)) {
            self.downloadMoreObjects()
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell", forIndexPath: indexPath) as! ProjectCell
        cell.object = tableData[indexPath.row]
        return cell
    }
    
    // MARK: - IBActions -
    
    @IBAction func rightBarButtonTouched(sender: AnyObject) {
        showSettingsAlert()
    }
    
    // MARK: - General Methods -
    
    func setupNavBar() {
        title = "Controlio"
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 237.0
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender: AnyObject?) {
        updateData()
    }
    
    func showSettingsAlert() {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let logoutAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Logout", comment:""), style: .Default) { action -> Void in
            self.showLogoutAlert()
        }
        alert.addAction(logoutAction)
        
        let changePasswordAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Change password", comment:""), style: .Default) { action -> Void in
            self.showChangePasswordAlert()
        }
        alert.addAction(changePasswordAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showLogoutAlert() {
        var alert = UIAlertController(title: NSLocalizedString("Точно выходим?", comment:""), message: NSLocalizedString("Придется опять залогиниться", comment:""), preferredStyle: .Alert)
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Нет", comment:""), style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let logoutAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Пока-пока", comment:""), style: .Default) { action -> Void in
            self.logout()
        }
        alert.addAction(logoutAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showChangePasswordAlert() {
        let alertController: UIAlertController = UIAlertController(title: NSLocalizedString("Change password", comment:""), message: nil, preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .Cancel) { action -> Void in
        }
        alertController.addAction(cancelAction)
        
        let changePassAction = UIAlertAction(title: NSLocalizedString("Reset password", comment:""), style: .Default) { (_) in
            let loginTextField = alertController.textFields![0] as! UITextField
            let oldPasswordTextField = alertController.textFields![1] as! UITextField
            let newPasswordTextField = alertController.textFields![2] as! UITextField
            self.tryChangePassword(loginTextField.text, oldPassword: oldPasswordTextField.text, newPassword: newPasswordTextField.text)
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = NSLocalizedString("Your login", comment:"")
            textField.keyboardType = .EmailAddress
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = NSLocalizedString("Current password", comment:"")
            textField.secureTextEntry = true
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = NSLocalizedString("New password", comment:"")
            textField.secureTextEntry = true
        }
        
        alertController.addAction(changePassAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func logout() {
        self.navigationController?.popToRootViewControllerAnimated(true)
        ServerManager.sharedInstance.logout()
    }
    
    func checkForProjectToShow() {
        var proj: ProjectObject? = PushNotificationsManager.sharedInstance.projectToShow
        if (proj != nil) {
            self.performSegueWithIdentifier("SegueToReports", sender: proj)
            PushNotificationsManager.sharedInstance.projectToShow = nil
        }
    }
    
    func tryChangePassword(login: String, oldPassword: String, newPassword: String) {
        ServerManager.sharedInstance.changePass(login, oldPass: oldPassword, newPass: newPassword) { (error: NSError?) -> () in
            if (error == nil) {
                var alert = UIAlertController(title: NSLocalizedString("Password was successfully changed", comment:""), message: "", preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("Ясно!", comment:""), style: .Cancel) { action -> Void in
                    
                }
                alert.addAction(cancelAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Table Data -
    
    func updateData() {
        ServerManager.sharedInstance.getProjects(0, count: 20, completion: { (error, objects) -> () in
            if (error == nil) {
                self.tableData = objects!
            } else {
                self.refreshControl!.endRefreshing()
            }
            self.noMoreData = false
        })
    }
    
    func downloadMoreObjects() {
        getDataWithOffset(tableData.count, count: 20)
    }
    
    func getDataWithOffset(offset: Int, count: Int) {
        ServerManager.sharedInstance.getProjects(offset, count: count, completion: { (error, objects) -> () in
            if (error == nil) {
                self.addDataObjects(objects!, offset: offset)
            }
        })
    }
    
    func addDataObjects(objects: [ProjectObject], offset: Int) {
        if (offset == 0) {
            noMoreData = false
            tableData = objects
        } else {
            if (objects.count > 0) {
                tableData += objects
            }
            noMoreData = objects.count == 0
        }
    }
    
    func isLastCellAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return tableData.count > 0 && indexPath.row == tableData.count - 1;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! ProjectCell
        
        self.performSegueWithIdentifier("SegueToReports", sender: cell.object)
    }
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as! StatusesViewController
        dest.object = sender as! ProjectObject
    }
}