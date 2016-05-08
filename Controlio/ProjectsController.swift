//
//  ProjectsController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ProjectsController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Variables -
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - UISearchResultsUpdating -
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    // MARK: - UISearchBarDelegate -
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        title = searchBar.scopeButtonTitles![selectedScope]
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(ProjectCell), forIndexPath: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Router(self).showProject()
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        setupTableView()
        addRefreshControl()
        setupSearchController()
        addSearchButton()
        setupBackButton()
    }
    
    // MARK: - Public Functions -
    
    func showSearch() {
        presentViewController(searchController, animated: true) {}
    }
    
    func loadData() {
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Private Functions -
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.registerNib(UINib(nibName: String(ProjectCell), bundle: nil), forCellReuseIdentifier: String(ProjectCell))
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProjectsController.loadData), forControlEvents: .ValueChanged)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All projects", "Completed", "In progress"]
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.barTintColor = UIColor.controlioViolet()
        searchController.searchBar.setCursorTintColor(UIColor.lightGrayColor())
        definesPresentationContext = true
    }
    
    private func addSearchButton() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(ProjectsController.showSearch))
        navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
}
