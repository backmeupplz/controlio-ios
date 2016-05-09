//
//  ProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ProjectController: UITableViewController, PostCellDelegate {
    
    // MARK: - Variables -
    
    var project: Project!
    
    // MARK: - Private Variables -
    
    var needsHeaderViewLayout = true
    
    // MARK: - Outlets -
    
    @IBOutlet private weak var headerView: UIView!
    
    @IBOutlet private weak var projectImageView: UIImageView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project.posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(PostCell), forIndexPath: indexPath) as! PostCell
        cell.post = project.posts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    // MARK: - PostCellDelegate -
    
    func openAttachment(index: Int, post: Post) {
        print("open attachment: \(index)")
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        checkHeaderViewHeight()
    }
    
    // MARK: - Public Functions -
    
    func loadData() {
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Private Functions -
    
    private func configure() {
        title = project.title
        
        projectImageView.loadURL(project.image)
        statusLabel.text = project.status
        dateLabel.text = NSDateFormatter.projectDateString(project.dateCreated)
        descriptionLabel.text = project.projectDescription
        
        tableView.reloadData()
        
        needsHeaderViewLayout = true
        checkHeaderViewHeight()
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.registerNib(UINib(nibName: String(PostCell), bundle: nil), forCellReuseIdentifier: String(PostCell))
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProjectController.loadData), forControlEvents: .ValueChanged)
    }
    
    private func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    private func checkHeaderViewHeight() {
        if needsHeaderViewLayout {
            let screenWidth = UIScreen.mainScreen().bounds.width
            let labelWidth = screenWidth - CGFloat(60)
            let labelHeight = project.projectDescription.heightWithConstrainedWidth(labelWidth, font: descriptionLabel.font)
            headerView.frame.size.height = 131 + labelHeight
            tableView.tableHeaderView = headerView
            needsHeaderViewLayout = false
        }
    }
    
    // MARK: - Rotations -
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        needsHeaderViewLayout = true
        coordinator.animateAlongsideTransition({ context in
                self.checkHeaderViewHeight()
            }) { context in
                // Completion
        }
    }
}
