//
//  ProjectsController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll

class ProjectsController: UITableViewController, ProjectControllerDelegate {
    
    // MARK: - Variables -
    
    fileprivate var projects = [Project]()
    
    // MARK: - ProjectControllerDelegate -
    
    func didDeleteProject(project: Project) {
        let index = projects.index(of: project)!
        
        projects.remove(at: index)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
        tableView.endUpdates()
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
        Router(self).showProject(projects[(indexPath as NSIndexPath).row], delegate: self)
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
        setupBackButton()
        
        addInfiniteScrolling()
        loadInitialProjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.register(UINib(nibName: "ProjectCell", bundle: nil), forCellReuseIdentifier: "ProjectCell")
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProjectsController.loadInitialProjects), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Pagination -
    
    fileprivate func addInfiniteScrolling() {
        tableView.addInfiniteScroll
        { tableView in
            self.loadMoreProjects()
        }
    }
    
    @objc fileprivate func loadInitialProjects() {
        Server.getProjects
        { error, projects in
            if let error = error {
                PopupNotification.show(notification: error.domain)
            } else {
                self.addInitialProjects(projects: projects!)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func loadMoreProjects() {
        Server.getProjects(skip: projects.count)
        { error, projects in
            if let error = error {
                PopupNotification.show(notification: error.domain)
            } else {
                self.addProjects(projects: projects!)
            }
            self.tableView.finishInfiniteScroll()
        }
    }
    
    fileprivate func addInitialProjects(projects: [Project]) {
        let indexPathsToDelete = IndexPath.range(start: 0, length: self.projects.count)
        self.projects = projects
        let indexPathsToAdd = IndexPath.range(start: 0, length: projects.count)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPathsToDelete, with: .fade)
        tableView.insertRows(at: indexPathsToAdd, with: .fade)
        tableView.endUpdates()
    }
    
    fileprivate func addProjects(projects: [Project]) {
        let indexPaths = IndexPath.range(start: self.projects.count, length: projects.count)
        self.projects += projects
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .bottom)
        tableView.endUpdates()
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
