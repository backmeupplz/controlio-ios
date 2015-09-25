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
        configureTableView()
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    // MARK: - IBOutlet -
    
    @IBAction func managerPhoneTouched(sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Звоним?", comment:""), message: sender.titleLabel!.text, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Нет", comment:""), style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let callAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Звоним!", comment:""), style: .Default) { action -> Void in
            var urlString = sender.titleLabel!.text!
            urlString = urlString.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            urlString = "tel://\(urlString)"
            
            UIApplication.sharedApplication().openURL(NSURL(string:urlString)!)
        }
        alert.addAction(callAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func managerEmailTouched(sender: UIButton) {
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients([sender.titleLabel!.text!])
        let prefix = NSLocalizedString("Вопрос по проекту", comment:"")
        picker.setSubject("\(prefix) '\(self.object.title)'")
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func managerWebsiteTouched(sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Переходим по ссылке?", comment:""), message: sender.titleLabel!.text, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Нет", comment:""), style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let websiteAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Переходим!", comment:""), style: .Default) { action -> Void in
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ProjectDescriptionCell") as! ProjectDescriptionCell
        cell.object = object
        return cell
    }
    
    // MARK: - MFMailComposeViewControllerDelegate -
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
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