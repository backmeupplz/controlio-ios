//
//  ProjectInfoViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 18/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class ProjectInfoViewController: UITableViewController {
    
    // MARK: - Public Variables -
    
    var object: ProjectObject!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ProjectDescriptionCell") as! ProjectDescriptionCell
        cell.object = object
        return cell
    }
    
    // MARK: - General Methods -
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
    }
}