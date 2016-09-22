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
    
    fileprivate let searchController = CustomSearchController(searchResultsController: nil)
    fileprivate var projects = [Project]()
    
    // MARK: - UISearchResultsUpdating -
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    // MARK: - UISearchBarDelegate -
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        title = searchBar.scopeButtonTitles![selectedScope]
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectCell
        cell.project = projects[(indexPath as NSIndexPath).row]
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Router(self).showProject(projects[(indexPath as NSIndexPath).row])
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
        present(searchController, animated: true) {}
    }
    
    // MARK: - Private Functions -
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.register(UINib(nibName: "ProjectCell", bundle: nil), forCellReuseIdentifier: "ProjectCell")
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
//        refreshControl?.addTarget(self, action: #selector(ProjectsController.loadData), for: .valueChanged)
    }
    
    fileprivate func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All projects", "Completed", "In progress"]
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.controlioViolet()
        searchController.searchBar.setCursorTintColor(UIColor.lightGray)
        definesPresentationContext = true
    }
    
    fileprivate func addSearchButton() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ProjectsController.showSearch))
        navigationItem.rightBarButtonItem = searchButton
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
