//
//  ProjectsController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD
import DZNEmptyDataSet
import Material
import AsyncDisplayKit

class ProjectsController: ASViewController<ASDisplayNode>, ProjectApproveCellDelegate {
    
    // MARK: - Variables -
    
    fileprivate var tableNode: ASTableNode!
    
    fileprivate var invites = [Invite]()
    fileprivate var projects = [Project]()
    
    fileprivate var isLoading = true
    fileprivate var needsMoreProjects = false
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var scope = ProjectSearchType.all
    fileprivate var query = ""

    
    fileprivate var refreshControl: UIRefreshControl?
    
    // MARK: - View Controller Life Cycle -
    
    init() {
        let tableNode = ASTableNode(style: .plain)
        
        super.init(node: tableNode)
        
        self.tableNode = tableNode
        self.tableNode.dataSource = self
        self.tableNode.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupTableView()
        addRefreshControl()
        setupBackButton()

        loadInitialProjects()
        subscribe()
    }
    
    deinit {
        unsubscribe()
    }
    
    // MARK: - ProjectControllerDelegate -
    
    func didDeleteProject(project: Project) {
        guard let index = projects.index(of: project) else { return }
        
        projects.remove(at: index)
        
        tableNode.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
    }
    
    // MARK: - ProjectApproveCell -
    
    func checkTouched(at cell: ProjectApproveCell) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.detailsLabel.text = NSLocalizedString("Accepting the invite...", comment: "invite accept message")
        Server.invite(approve: true, invite: cell.invite)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                guard let index = self.invites.index(of: cell.invite) else { return }
                self.snackbarController?.show(text: String(format: NSLocalizedString("You have accepted the invite to \"%@\"", comment: "invite accept success message"), cell.invite.project!.title ?? ""))
                self.invites = self.invites.filter { $0 != cell.invite }
                self.tableNode.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                self.loadInitialOnlyProjects()
            }
        }
    }
    
    func crossTouched(at cell: ProjectApproveCell) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.detailsLabel.text = NSLocalizedString("Rejecting the invite...", comment: "invite reject message")
        Server.invite(approve: false, invite: cell.invite)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                guard let index = self.invites.index(of: cell.invite) else { return }
                self.snackbarController?.show(text: String(format: NSLocalizedString("You have rejected the invite to \"%@\"", comment: "invite reject success message"), cell.invite.project!.title ?? ""))
                self.invites = self.invites.filter { $0 != cell.invite }
                self.tableNode.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    // MARK: - Private Functions -
    
    fileprivate func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.controlioViolet
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.sizeToFit()
        tableNode.view.setContentOffset(CGPoint(x:0, y:searchController.searchBar.frame.height), animated: false)
    }
    
    fileprivate func setupScopeBar(){
        searchController.searchBar.scopeButtonTitles = [
            ProjectSearchType.all.rawValue.capitalized,
            ProjectSearchType.live.rawValue.capitalized,
            ProjectSearchType.finished.rawValue.capitalized
        ]
        tableNode.view.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func setupTabBar() {
        navigationController?.tabBarItem.image = R.image.projects()
        navigationController?.tabBarItem.title = NSLocalizedString("Projects", comment: "tabbar title")
    }
    
    fileprivate func setupTableView() {
        tableNode.view.tableFooterView = UIView()
        tableNode.view.separatorStyle = .none
        tableNode.view.backgroundColor = Color.controlioTableBackground
        tableNode.view.contentInset = EdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }

    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        guard let refreshControl = refreshControl else { return }
        tableNode.view.addSubview(refreshControl)
        tableNode.view.sendSubview(toBack: refreshControl)
        refreshControl.addTarget(self, action: #selector(ProjectsController.loadInitialProjects), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Notifications -
    
    fileprivate func subscribe() {
        subscribe(to: [
            .projectCreated: #selector(ProjectsController.projectCreated),
            .projectDeleted: #selector(ProjectsController.projectDeleted),
            .projectArchivedChanged: #selector(ProjectsController.projectIsArchivedChanged)
        ])
    }
    
    func projectCreated(){
        loadInitialProjects()
    }

    func projectDeleted(){
        loadInitialProjects()
    }
    
    func projectIsArchivedChanged(){
        loadInitialProjects()
    }
    
    // MARK: - Pagination -
    
    @objc fileprivate func loadInitialProjects(silent: Bool = false) {
        isLoading = true
        cleanTableView()
        if !silent {
            refreshControl?.beginRefreshing()
        }
        let tempQuery = query
        let tempScope = scope
        
        Server.getInvites
        { error, invites in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let invites = invites {
                self.invites = invites
                self.tableNode.reloadSections(IndexSet(integer: 0), with: .fade)
            }
        }
        Server.getProjects(type: scope, query: query)
        { error, projects in
            self.isLoading = false
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let projects = projects, tempQuery == self.query, tempScope == self.scope {
                self.addInitialProjects(projects: projects)
            } else {
                self.tableNode.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func loadInitialOnlyProjects() {
        refreshControl?.beginRefreshing()
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
    
    fileprivate func loadMoreProjects(completion: @escaping ()->()) {
        Server.getProjects(skip: projects.count)
        { error, projects in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let projects = projects {
                self.addProjects(projects: projects)
            }
            completion()
        }
    }
    
    fileprivate func addInitialProjects(projects: [Project]) {
        needsMoreProjects = true
        self.projects = projects
        
        tableNode.reloadSections(IndexSet(integer: 1), with: .fade)
    }
    
    fileprivate func addProjects(projects: [Project]) {
        if projects.count == 0 {
            needsMoreProjects = false
        }
        let indexPaths = IndexPath.range(start: self.projects.count, length: projects.count, section: 1)
        self.projects += projects
        
        tableNode.insertRows(at: indexPaths, with: .bottom)
    }
    
    fileprivate func cleanTableView() {
        var indexPathsToDelete = IndexPath.range(start: 0, length: projects.count, section: 1)
        if !searchController.isActive {
            indexPathsToDelete += IndexPath.range(start: 0, length: invites.count, section: 0)
            invites = []
        }
        projects = []
        tableNode.view.beginUpdates()
        tableNode.view.deleteRows(at: indexPathsToDelete, with: .fade)
        tableNode.view.endUpdates()
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension ProjectsController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? projects.count : invites.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            if indexPath.section == 0 {
                return ProjectApproveCell(with: self.invites[indexPath.row],
                                          delegate: self)
            } else {
                return ProjectCell(with: self.projects[indexPath.row],
                                   type: .list)
            }
        }
    }
}

extension ProjectsController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let project = invites[indexPath.row].project {
                Router(self).show(project: project)
            }
        } else {
            Router(self).show(project: projects[indexPath.row])
        }
    }
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return needsMoreProjects
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        loadMoreProjects
            {
                context.completeBatchFetching(true)
        }
    }
}

extension ProjectsController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = isLoading ? NSLocalizedString("Loading...", comment: "empty view placeholder"): NSLocalizedString("You don't have any projects yet", comment: "empty view placeholder")
        let attributes = [
            NSFontAttributeName: Font.boldSystemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: Color.darkGray
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = isLoading ? NSLocalizedString("Let us get your projects from the cloud", comment: "empty view placeholder"): NSLocalizedString("You can create your first project", comment: "empty view placeholder")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping;
        paragraph.alignment = .center;
        
        let attributes = [
            NSFontAttributeName: Font.boldSystemFont(ofSize: 14.0),
            NSForegroundColorAttributeName: Color.lightGray,
            NSParagraphStyleAttributeName: paragraph
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes = [
            NSFontAttributeName: Font.boldSystemFont(ofSize: 17.0),
            NSForegroundColorAttributeName: Color.controlioGreen,
            ]
        
        return NSAttributedString(string: NSLocalizedString("Create project", comment: "empty view button title"), attributes: attributes)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 60
    }
}

extension ProjectsController: DZNEmptyDataSetDelegate {
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        navigationController?.tabBarController?.selectedIndex = 1
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

extension ProjectsController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        query = searchBar.text ?? ""
        let scopeTitle = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex].lowercased() ?? ""
        scope = ProjectSearchType(rawValue: scopeTitle) ?? .all
        //loadInitial(silent: true)
    }
}

extension ProjectsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        query = searchBar.text ?? ""
        let scopeTitle = searchBar.scopeButtonTitles?[selectedScope].lowercased() ?? ""
        scope = ProjectSearchType(rawValue: scopeTitle) ?? .all
        //loadInitial(silent: true)
    }
}

