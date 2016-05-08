//
//  ProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ProjectController: UITableViewController {
    
    // MARK: - Variables -
    
    var project: Project! {
        didSet {
            configure()
        }
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
        setupBackButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
    }
    
    // MARK: - Public Functions -
    
    func loadData() {
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Private Functions -
    
    private func configure() {
        title = project.title
        
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.registerNib(UINib(nibName: String(ProjectCell), bundle: nil), forCellReuseIdentifier: String(ProjectCell))
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProjectController.loadData), forControlEvents: .ValueChanged)
    }
    
    private func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
}
