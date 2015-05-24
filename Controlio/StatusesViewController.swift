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
    
    var tableData = [StatusObject]() {
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        configureTableView()
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count + 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0 || indexPath.row == tableData.count + 1) {
            return tableView.dequeueReusableCellWithIdentifier("Placeholder") as! UITableViewCell
        }
        
        if (!noMoreData && isLastCellAtIndexPath(indexPath)) {
            self.downloadMoreObjects()
        }
        
        var object = tableData[indexPath.row-1] as StatusObject
        var cell = tableView.dequeueReusableCellWithIdentifier("StatusCell\(object.type.simpleDescription())", forIndexPath: indexPath) as! StatusCell
        
        cell.manager = self.object.manager
        cell.object = object
        cell.delegate = self
        return cell
    }
    
    // MARK: - General Methods -
    
    func setupNavBar() {
        title = object.title
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
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
    
    func updateData() {
        ServerManager.sharedInstance.getStatuses(object.identificator, offset: 0, count: 20, completion: { (error, objects) -> () in
            if (error == nil) {
                self.tableData = objects!
            } else {
                self.refreshControl!.endRefreshing()
            }
            self.noMoreData = false
        })
    }
    
    func downloadMoreObjects() {
        getDataWithOffset(getRealTableDataCount(), count: 20)
    }
    
    func getDataWithOffset(offset: Int, count: Int) {
        ServerManager.sharedInstance.getStatuses(object.identificator, offset: offset, count: count, completion: { (error, objects) -> () in
            if (error == nil) {
                self.addDataObjects(objects!, offset: offset)
            }
        })
    }
    
    func addDataObjects(objects: [StatusObject], offset: Int) {
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
        return tableData.count > 0 && indexPath.row-1 == tableData.count - 1;
    }
    
    func getRealTableDataCount() -> Int {
        var i = 0
        
        for status in tableData {
            if (status.type != .Time) {
                i++
            }
        }
        
        return i
    }
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as! ProjectInfoViewController
        dest.object = object
    }
}