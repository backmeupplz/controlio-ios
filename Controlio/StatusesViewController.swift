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
        setupRefreshControl()
        populateFakeData()
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
            loadMoreData()
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
    
    func populateFakeData() {
        for index in 0...20 {
            var obj = StatusObject()
            if (index % 3 == 0) {
                obj.type = .TypeChange
                obj.text = "Начали проект!"
            } else if (index % 2 == 0) {
                obj.type = .Time
                obj.text = "21 мая 2015"
            } else {
                obj.type = StatusType.StatusWithImage
                obj.text = "Артемий Андреевич Лебедев – наш человек! Съел горстку печалий и больше не ест :3 Подписывайтесь на tema.livejournal.ru"
                
                var att = [NSURL]()
                for inde in 0...3 {
                    att.append(NSURL(string: "https://pp.vk.me/c623428/v623428806/230e6/FFhZXh0DlZc.jpg")!)
                }
                obj.attachements = att
            }
            tableData.append(obj)
        }
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender: AnyObject?) {
        refreshControl!.endRefreshing()
    }
    
    func loadMoreData() {
        println("load more data!")
    }
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as! ProjectInfoViewController
        dest.object = object
    }
}