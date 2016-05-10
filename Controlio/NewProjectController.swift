//
//  NewProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class NewProjectController: UITableViewController, NewProjectCellDelegate {
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(NewProjectCell), forIndexPath: indexPath) as! NewProjectCell
        cell.delegate = self
        return cell
    }

    // MARK: - NewProjectCellDelegate -
    
    func editPhotoTouched() {
        print("edit photo")
    }
    
    func chooseManagerTouched() {
        print("choose manager")
    }
    
    func createTouched() {
        print("create")
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBackButton()
    }
    
    // MARK: - Private Functions -
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.registerNib(UINib(nibName: String(NewProjectCell), bundle: nil), forCellReuseIdentifier: String(NewProjectCell))
    }
    
    private func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
}
