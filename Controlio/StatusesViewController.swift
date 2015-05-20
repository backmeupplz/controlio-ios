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
        
        populateFakeData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var object = tableData[indexPath.row] as StatusObject
        var cell = tableView.dequeueReusableCellWithIdentifier("StatusCell\(object.type.simpleDescription())") as! StatusCell
        
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
                for inde in 0...0 {
                    att.append(NSURL(string: "https://pp.vk.me/c623428/v623428806/230e6/FFhZXh0DlZc.jpg")!)
                }
                obj.attachements = att
            }
            tableData.append(obj)
        }
    }
    
    // MARK: - Segues -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as! ProjectInfoViewController
        dest.object = object
    }
}