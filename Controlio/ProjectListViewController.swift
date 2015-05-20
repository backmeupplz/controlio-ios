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
    
    var tableData = [ProjectObject]()
    
    // MARK: - IBActions -
    
    @IBAction func rightBarButtonTouched(sender: AnyObject) {
        showLogoutAlert()
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateFakeData()
        setupRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Controlio"
        navigationItem.setHidesBackButton(true, animated: false)
        configureTableView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.title = ""
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell") as! ProjectCell
        cell.object = tableData[indexPath.row]
        return cell
    }
    
    // MARK: - General Methods -
    
    func showLogoutAlert() {
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
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 237.0
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender: AnyObject?) {
        refreshControl!.endRefreshing()
    }
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as! StatusesViewController
        let unwrappedSender = sender as! ProjectCell
        dest.object = unwrappedSender.object
    }
    
    // MARK: - Debug -
    
    func populateFakeData() {
        for index in 0...20 {
            var obj = ProjectObject()
            
            obj.identificator = index
            obj.image = NSURL(string: "https://i.ytimg.com/vi/YWNWi-ZWL3c/maxresdefault.jpg")
            obj.title = "Some title #\(index)"
            obj.timestamp = Int(NSDate().timeIntervalSince1970)
            obj.message = "Some message #\(index)"
            obj.info = "This is one of the best project we've had our hands on!"
            obj.status = "Тесты"
            
            var manager = ManagerObject()
            manager.image = NSURL(string: "https://pp.vk.me/c608619/v608619806/8f47/Vv-VLk2JbCU.jpg")
            manager.name = "Nikita Kolmogorov"
            manager.telephone = "+1 778 288 1444"
            manager.email = "nikita@borodutch.com"
            manager.website = "www.borodutch.com"
            
            obj.manager = manager
            
            tableData.append(obj)
        }
    }
}