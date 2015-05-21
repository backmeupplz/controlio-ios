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
        
        title = "Controlio"
        loadMoreData()
        setupRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        navigationItem.setHidesBackButton(true, animated: false)
        configureTableView()
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row >= tableData.count-1) {
//            loadMoreData()
        }
        
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
        ServerManager.sharedInstance.logout()
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
        ServerManager.sharedInstance.getProjects(0, count: 20, completion: { (error, objects) -> () in
            if (error == nil) {
                self.tableData = objects!
                self.tableView.reloadData()
                self.tableView.layoutSubviews()
            }
            self.refreshControl!.endRefreshing()
        })
    }
    
    func loadMoreData() {
        ServerManager.sharedInstance.getProjects(tableData.count, count: 20, completion: { (error, objects) -> () in
            if (error == nil) {
                var temp = objects!
                temp += self.tableData
                self.tableData = temp
            }
            self.tableView.reloadData()
            self.tableView.layoutSubviews()
        })
    }
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as! StatusesViewController
        let unwrappedSender = sender as! ProjectCell
        dest.object = unwrappedSender.object
    }
}