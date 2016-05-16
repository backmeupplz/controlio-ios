//
//  ProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ProjectController: UITableViewController, PostCellDelegate, InputViewDelegate {
    
    // MARK: - Variables -
    
    var project: Project!
    
    // MARK: - Private Variables -
    
    private var needsHeaderViewLayout = true
    private var input: InputView?
    private let imagePicker = UIImagePickerController()
    
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
    
    // MARK: - InputViewDelegate -
    
    func openPickerWithDelegate(delegate: PickerDelegate) {
        imagePicker.allowsEditing = false
        imagePicker.delegate = delegate
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        alert.addDefaultAction("Camera") { 
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        alert.addDefaultAction("Library") { 
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        alert.addCancelButton()
        alert.addPopoverSourceView(input!)
        
        self.presentViewController(alert, animated: true) { }
    }
    
    func closeImagePicker() {
        dismissViewControllerAnimated(true) { }
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
        setupBackButton()
        setupInput()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        
        showInput()
        
        IQKeyboardManager.sharedManager().enable = false
        subcribeForNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        checkHeaderViewHeight()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotifications()
        hideInput()
        
        IQKeyboardManager.sharedManager().enable = true
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
    
    private func setBottomScrollInset(inset: CGFloat) {
        let scrollIndicatorInsets = tableView.scrollIndicatorInsets
        let contentInset = tableView.contentInset
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollIndicatorInsets.top,
                                                           scrollIndicatorInsets.left,
                                                           inset,
                                                           scrollIndicatorInsets.right)
        tableView.contentInset = UIEdgeInsetsMake(contentInset.top,
                                                  contentInset.left,
                                                  inset,
                                                  contentInset.right)
    }
    
    private func setupInput() {
        input = InputView.view(navigationController!.view, vc: self, delegate: self)
    }
    
    private func showInput() {
        if project.canEdit {
            input?.show()
            setBottomScrollInset(input?.frame.height ?? 0)
        }
    }
    
    private func hideInput() {
        input?.hide()
    }
    
    // MARK: - Notifications -
    
    private func subcribeForNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(ProjectController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ProjectController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue))
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        input?.changeBottomSpacing(keyboardHeight)
        UIView.animateWithDuration(duration,
                                   delay: 0,
                                   options: options,
                                   animations: { 
                                    self.input?.layoutIfNeeded()
            }) { finished in }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue))
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        input?.changeBottomSpacing(0)
        UIView.animateWithDuration(duration,
                                   delay: 0,
                                   options: options,
                                   animations: {
                                    self.input?.layoutIfNeeded()
        }) { finished in }
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
    
    // MARK: - Status Bar -
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
