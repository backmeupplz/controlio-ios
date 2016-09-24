//
//  EditProfileViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class EditProfileViewController: UITableViewController, EditProfileCellDelegate {

    // MARK: - Variables -
    
    var user: User! {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Outlets -
    
    @IBAction func saveTouched(_ sender: AnyObject) {
        // TODO: save
        let _ = navigationController?.popViewController(animated: true)
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
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell", for: indexPath) as! EditProfileCell
        cell.user = user
        cell.delegate = self
        return cell
    }
    
    // MARK: - EditProfileCellDelegate -
    
    func editPhotoTouched() {
        
    }
    
    // MARK: - Functions -
    
    func loadData() {
        refreshControl?.beginRefreshing()
        Server.getProfile
            { error, user in
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                } else {
                    self.user = user
                }
                self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "EditProfileCell", bundle: nil), forCellReuseIdentifier: "EditProfileCell")
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProjectController.loadData), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
