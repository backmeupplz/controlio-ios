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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: false)
        configureTableView()
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
    
    // MARK: - Debug -
    
    func populateFakeData() {
        for index in 0...20 {
            var obj = ProjectObject()
            
            obj.identificator = index
            obj.lastImage = NSURL(string: "https://i.ytimg.com/vi/YWNWi-ZWL3c/maxresdefault.jpg")
            obj.titleMessage = "Some title #\(index)"
            obj.timestamp = Int(NSDate().timeIntervalSince1970)
            obj.lastMessage = "Some message #\(index)"
            
            tableData.append(obj)
        }
    }
}