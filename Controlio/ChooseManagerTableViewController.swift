//
//  ChooseManagerTableViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 21/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ChooseManagerTableViewController: UITableViewController {
    
    // MARK: - Variables -
    
    var managers = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Outlets -
    
    @IBAction func addTouched(_ sender: AnyObject) {
        performSegue(withIdentifier: "SegueToNewManager", sender: self)
    }
    
    // MARK: - View Controller Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return managers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.user = managers[indexPath.row]
        return cell
    }
    
    // MARK: - Functions -
    
    func loadData() {
        refreshControl?.beginRefreshing()
        Server.getManagers
        { error, users in
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                self.managers = users!
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProjectController.loadData), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
