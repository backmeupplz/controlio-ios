//
//  StatusesViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 18/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class StatusesViewController : UITableViewController {
    
    // MARK: - Public Variables -
    
    var object: ProjectObject!
    
    // MARK: - Variables -
    
    var tableData = [StatusObject]()
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = object.title
        loadMoreData()
        setupRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
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
        
        var object = tableData[indexPath.row] as StatusObject
        var cell = tableView.dequeueReusableCellWithIdentifier("StatusCell\(object.type.simpleDescription())", forIndexPath: indexPath) as! StatusCell
        
        cell.manager = self.object.manager
        cell.object = object
        return cell
    }
    
    // MARK: - General Methods -
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 103.0
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender: AnyObject?) {
        ServerManager.sharedInstance.getStatuses(object.identificator, offset: 0, count: 20) { (error, objects) -> () in
            if (error == nil) {
                self.tableData = objects!
                self.tableView.reloadData()
                self.tableView.layoutSubviews()
            }
            self.refreshControl!.endRefreshing()
        }
    }
    
    func loadMoreData() {
        ServerManager.sharedInstance.getStatuses(object.identificator, offset: tableData.count, count: 20) { (error, objects) -> () in
            if (error == nil) {
                var temp = objects!
                temp += self.tableData
                self.tableData = temp
            }
            self.tableView.reloadData()
            self.tableView.layoutSubviews()
        }
    }
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as! ProjectInfoViewController
        dest.object = object
    }
}