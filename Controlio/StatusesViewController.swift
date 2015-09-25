//
//  StatusesViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 18/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

enum EdditingModeType {
    case None
    case Post
    case Status
}

class StatusesViewController : UITableViewController {
    
    // MARK: - Public Variables -
    
    var object: ProjectObject!
    var edditingMode: EdditingModeType = .None {
        didSet {
            configureEdittingMode()
        }
    }
    
    // MARK: - Variables -
    
    var tableData = [StatusObject]() {
        didSet {
            tableView.reloadData()
            tableView.layoutSubviews()
            refreshControl?.endRefreshing()
        }
    }
    
    var noMoreData: Bool = false
    var plusButton: UIBarButtonItem?
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        configureTableView()
        setupRefreshControl()
        updateData()
        addPlusButtonIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        configureTableView()
    }
    
    // MARK: - AddStatusCellDelegate -
    
    func shouldDismissAddStatusCellDone() {
        edditingMode = .None
        updateData()
    }
    
    func shouldDismissAddStatusCellCancel() {
        edditingMode = .None
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return edditingMode != .None ? tableData.count + 1 : tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            if (edditingMode == .Status) {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddStatusCell") as! AddStatusCell
                cell.delegate = self
                cell.object = self.object
                return cell
            } else if (edditingMode == .Post) {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddPostCell") as! AddStatusCell
                cell.delegate = self
                cell.object = self.object
                return cell
            }
        }
        
        if (!noMoreData && isLastCellAtIndexPath(indexPath)) {
            self.downloadMoreObjects()
        }
        
        
        
        let object = tableData[edditingMode != .None ? indexPath.row-1 : indexPath.row] as StatusObject
        let cell = tableView.dequeueReusableCellWithIdentifier("StatusCell\(object.type.cellNameExtension())", forIndexPath: indexPath) as! StatusCell
        
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
        tableView.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
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
    
    func addPlusButtonIfNeeded() {
        if (object.adminRights!) {
            plusButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "plusTouched:")
            navigationItem.rightBarButtonItems?.append(plusButton!)
        }
    }
    
    func plusTouched(sender: UIBarButtonItem) {
        let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        alertController.addAction(cancelAction)
        
        let addStatusAction: UIAlertAction = UIAlertAction(title: "Add status", style: UIAlertActionStyle.Default) { action -> Void in
            self.edditingMode = .Status
        }
        alertController.addAction(addStatusAction)
        
        let addPostAction: UIAlertAction = UIAlertAction(title: "Add post", style: UIAlertActionStyle.Default) { action -> Void in
            self.edditingMode = .Post
        }
        alertController.addAction(addPostAction)
        
        alertController.popoverPresentationController?.barButtonItem = sender
        let controller = UIApplication.sharedApplication().delegate?.window??.rootViewController
        controller!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func configureEdittingMode() {
        plusButton?.enabled = edditingMode == .None
        
        tableView.beginUpdates()
        if (edditingMode != .None) {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Bottom)
            tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
        } else {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Right)
        }
        tableView.endUpdates()
    }
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! ProjectInfoViewController
        dest.object = object
    }
}