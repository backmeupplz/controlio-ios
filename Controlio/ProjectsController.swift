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
    private var projects = [Project]()
    
    // MARK: - UISearchResultsUpdating -
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    // MARK: - UISearchBarDelegate -
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        title = searchBar.scopeButtonTitles![selectedScope]
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(ProjectCell), forIndexPath: indexPath) as! ProjectCell
        cell.project = projects[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Router(self).showProject(projects[indexPath.row])
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    // MARK: - Public Functions -
    
    func showSearch() {
        presentViewController(searchController, animated: true) {}
    }
    
    func loadData() {
        DataManager.sharedManager.getProjects { projects in
            self.projects = projects!
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
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
    
    // MARK: - Status Bar -
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
}
