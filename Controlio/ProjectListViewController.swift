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
        showLogoutAlert()
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
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as! StatusesViewController
        let unwrappedSender = sender as! ProjectCell
        dest.object = unwrappedSender.object
    }
}