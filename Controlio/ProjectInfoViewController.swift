//
//  ProjectInfoViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 18/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class ProjectInfoViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - Public Variables -
    
    var object: ProjectObject!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = object.title
        setupRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
    }
    
    // MARK: - IBOutlet -
    
    @IBAction func managerPhoneTouched(sender: UIButton) {
        var alert = UIAlertController(title: "Звоним?", message: sender.titleLabel!.text, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Нет", style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let callAction: UIAlertAction = UIAlertAction(title: "Звоним!", style: .Default) { action -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string:"tel://\(sender.titleLabel!.text!)")!)
        }
        alert.addAction(callAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func managerEmailTouched(sender: UIButton) {
        var picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients([sender.titleLabel!.text!])
        picker.setSubject("Вопрос по проекту '\(self.object.title)'")
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func managerWebsiteTouched(sender: UIButton) {
        var alert = UIAlertController(title: "Переходим по ссылке?", message: sender.titleLabel!.text, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Нет", style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let websiteAction: UIAlertAction = UIAlertAction(title: "Переходим!", style: .Default) { action -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string:sender.titleLabel!.text!)!)
        }
        alert.addAction(websiteAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ProjectDescriptionCell") as! ProjectDescriptionCell
        cell.object = object
        return cell
    }
    
    // MARK: - MFMailComposeViewControllerDelegate -
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - General Methods -
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender: AnyObject?) {
        refreshControl!.endRefreshing()
    }
}