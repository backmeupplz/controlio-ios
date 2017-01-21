//
//  ProjectsController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll
import MBProgressHUD

class ProjectsController: UITableViewController, ProjectControllerDelegate, ProjectApproveCellDelegate {
    
    // MARK: - Variables -
    
    fileprivate var invites = [Invite]()
    fileprivate var projects = [Project]()
    
    // MARK: - ProjectControllerDelegate -
    
    func didDeleteProject(project: Project) {
        let index = projects.index(of: project)!
        
        projects.remove(at: index)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
        tableView.endUpdates()
    }
    
    // MARK: - ProjectApproveCell -
    
    func checkTouched(at cell: ProjectApproveCell) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = "Accepting the invite..."
        Server.invite(approve: true, invite: cell.invite)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.snackbarController?.show(text: "You have accepted the invite to \"\(cell.invite.project.title ?? "")\"")
                self.tableView.beginUpdates()
                self.invites = self.invites.filter { $0 != cell.invite }
                self.tableView.deleteRows(at: [self.tableView.indexPath(for: cell)!], with: .automatic)
                self.tableView.endUpdates()
                self.loadInitialOnlyProjects()
            }
        }
    }
    
    func crossTouched(at cell: ProjectApproveCell) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = "Rejecting the invite..."
        Server.invite(approve: false, invite: cell.invite)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.snackbarController?.show(text: "You have rejected the invite to \"\(cell.invite.project.title ?? "")\"")
                self.tableView.beginUpdates()
                self.invites = self.invites.filter { $0 != cell.invite }
                self.tableView.deleteRows(at: [self.tableView.indexPath(for: cell)!], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    // MARK: - UITableViewDataSource -
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? projects.count : invites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectApproveCell", for: indexPath) as! ProjectApproveCell
            cell.invite = invites[(indexPath as NSIndexPath).row]
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectCell
            cell.project = projects[(indexPath as NSIndexPath).row]
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Router(self).show(project: projects[(indexPath as NSIndexPath).row], delegate: self)
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
        tableView.register(UINib(nibName: "ProjectApproveCell", bundle: nil), forCellReuseIdentifier: "ProjectApproveCell")
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
        Server.getInvites
        { error, invites in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let invites = invites {
                self.invites = invites
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
        Server.getProjects
        { error, projects in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let projects = projects {
                self.addInitialProjects(projects: projects)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func loadInitialOnlyProjects() {
        tableView.refreshControl?.beginRefreshing()
        Server.getProjects
            { error, projects in
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else if let projects = projects {
                    self.addInitialProjects(projects: projects)
                }
                self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func loadMoreProjects() {
        Server.getProjects(skip: projects.count)
        { error, projects in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.addProjects(projects: projects!)
            }
            self.tableView.finishInfiniteScroll()
        }
    }
    
    fileprivate func addInitialProjects(projects: [Project]) {
        let indexPathsToDelete = IndexPath.range(start: 0, length: self.projects.count, section: 1)
        self.projects = projects
        let indexPathsToAdd = IndexPath.range(start: 0, length: projects.count, section: 1)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPathsToDelete, with: .fade)
        tableView.insertRows(at: indexPathsToAdd, with: .fade)
        tableView.endUpdates()
    }
    
    fileprivate func addProjects(projects: [Project]) {
        let indexPaths = IndexPath.range(start: self.projects.count, length: projects.count, section: 1)
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
