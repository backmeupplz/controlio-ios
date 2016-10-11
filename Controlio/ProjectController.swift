//
//  ProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProjectController: UITableViewController, PostCellDelegate, InputViewDelegate {
    
    // MARK: - Variables -
    
    var project: Project!
    var posts = [Post]()
    
    // MARK: - Private Variables -
    
    fileprivate var needsHeaderViewLayout = true
    fileprivate var input: InputView?
    fileprivate let imagePicker = UIImagePickerController()
    
    fileprivate var currentGallery: ImageGallery?
    
    // MARK: - Outlets -
    
    @IBOutlet fileprivate weak var headerView: UIView!
    
    @IBOutlet fileprivate weak var projectImageView: UIImageView!
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.post = posts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    // MARK: - PostCellDelegate -
    
    func openAttachment(_ index: Int, post: Post, fromView: UIView) {
        currentGallery = ImageGallery()
        currentGallery?.showGallery(atViewController: self, index: index, imageKeys: post.attachments, fromView: fromView)
    }
    
    func edit(post: Post, cell: PostCell) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        let edit = UIAlertAction(title: "Edit", style: .default)
        { action in
            self.input?.post = post
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive)
        { action in
            self.delete(post: post, cell: cell)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        { action in
            // Do nothing
        }
        
        if Date().timeIntervalSince1970 - post.dateCreated.timeIntervalSince1970 < 60*60*3 {
            alert.addAction(edit)
        }
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - InputViewDelegate -
    
    func openPicker(with delegate: PickerDelegate, sender: UIView) {
        imagePicker.allowsEditing = false
        imagePicker.delegate = delegate
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        alert.addDefaultAction("Camera") { 
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.addDefaultAction("Library") { 
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.addCancelButton()
        alert.addPopoverSourceView(input!)
        
        self.present(alert, animated: true) { }
    }
    
    func closeImagePicker() {
        dismiss(animated: true) { }
    }
    
    func shouldAddPost(text: String, attachments: [Any]) {
        if text.isEmpty && attachments.count <= 0 {
            PopupNotification.showNotification("Please provide at least one attachment or text")
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        
        let completedKeys = attachments.filter { $0 is String } as! [String]
        let imagesToUpload = attachments.filter { $0 is UIImage } as! [UIImage]
        
        if imagesToUpload.count > 0 {
            hud.mode = .annularDeterminate
            hud.label.text = "Uploading attachments"
            S3.upload(images: imagesToUpload, progress:
            { progress in
                hud.progress = progress
            })
            { keys, error in
                if let error = error {
                    PopupNotification.showNotification(error)
                    hud.hide(animated: true)
                } else {
                    hud.mode = .indeterminate
                    hud.label.text = "Uploading data"
                    Server.addPost(projectId: self.project.id, text: text, attachmentKeys: keys!+completedKeys)
                    { error in
                        if let error = error {
                            PopupNotification.showNotification(error.domain)
                            hud.hide(animated: true)
                        } else {
                            hud.hide(animated: true)
                            self.reloadAndCleanInput()
                        }
                    }
                }
            }
        } else {
            hud.mode = .indeterminate
            hud.label.text = "Uploading data"
            Server.addPost(projectId: project.id, text: text, attachmentKeys: completedKeys)
            { error in
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                    hud.hide(animated: true)
                } else {
                    hud.hide(animated: true)
                    self.reloadAndCleanInput()
                }
            }
        }
    }
    
    func shouldChangeStatus(text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        hud.label.text = "Uploading data"
        Server.changeStatus(projectId: project.id, status: text)
        { error in
            if let error = error {
                PopupNotification.showNotification(error.domain)
                hud.hide(animated: true)
            } else {
                hud.hide(animated: true)
                self.project.lastStatus?.text = text
                self.configure()
                self.reloadAndCleanInput()
            }
        }
    }
    
    func shouldEditClients(clients: [String]) {
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        hud.label.text = "Uploading data"
        Server.changeClients(projectId: project.id, clientEmails: clients)
        { error in
            hud.hide(animated: true)
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                PopupNotification.showNotification("Clients saved")
                self.project.clients = []
                for client in clients {
                    let user = User()
                    user.email = client
                    self.project.clients.append(user)
                }
                
            }
        }
    }
    
    func shouldEditPost(post: Post, text: String, attachments: [Any]) {
        if text.isEmpty && attachments.count <= 0 {
            PopupNotification.showNotification("Please provide at least one attachment or text")
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        
        let completedKeys = attachments.filter { $0 is String } as! [String]
        let imagesToUpload = attachments.filter { $0 is UIImage } as! [UIImage]
        
        if imagesToUpload.count > 0 {
            hud.mode = .annularDeterminate
            hud.label.text = "Uploading attachments"
            S3.upload(images: imagesToUpload, progress:
                { progress in
                    hud.progress = progress
                })
            { keys, error in
                if let error = error {
                    PopupNotification.showNotification(error)
                    hud.hide(animated: true)
                } else {
                    hud.mode = .indeterminate
                    hud.label.text = "Uploading data"
                    Server.editPost(post: post, text: text, attachments: keys!+completedKeys)
                    { error in
                        hud.hide(animated: true)
                        if let error = error {
                            PopupNotification.showNotification(error.domain)
                        } else {
                            self.input?.post = nil
                            post.text = text
                            post.attachments = keys!+completedKeys
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [IndexPath(row: self.posts.index(of: post)!, section: 0)], with: .fade)
                            self.tableView.endUpdates()
                        }
                    }
                }
            }
        } else {
            hud.mode = .indeterminate
            hud.label.text = "Uploading data"
            Server.editPost(post: post, text: text, attachments: completedKeys)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                } else {
                    self.input?.post = nil
                    post.text = text
                    post.attachments = completedKeys
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: self.posts.index(of: post)!, section: 0)], with: .fade)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
        setupBackButton()
        setupEditButton()
        setupInput()
        
        addInfiniteScrolling()
        loadInitialPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        showInput()
        subcribeForNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        checkHeaderViewHeight()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotifications()
        hideInput()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configure() {
        title = project.title
        
        projectImageView.load(key: project.imageKey)
        statusLabel.text = project.lastStatus?.text
        dateLabel.text = DateFormatter.projectDateString(project.dateCreated)
        descriptionLabel.text = project.projectDescription
        
        tableView.reloadData()
        
        needsHeaderViewLayout = true
        checkHeaderViewHeight()
    }
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProjectController.loadInitialPosts), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupEditButton() {
        if project.canEdit {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ProjectController.openEdit))
        }
    }
    
    fileprivate func checkHeaderViewHeight() {
        if needsHeaderViewLayout {
            let screenWidth = UIScreen.main.bounds.width
            let labelWidth = screenWidth - CGFloat(60)
            let labelHeight = project.projectDescription.heightWithConstrainedWidth(labelWidth, font: descriptionLabel.font)
            headerView.frame.size.height = 131 + labelHeight
            tableView.tableHeaderView = headerView
            needsHeaderViewLayout = false
        }
    }
    
    fileprivate func setBottomScrollInset(_ inset: CGFloat) {
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
    
    fileprivate func setupInput() {
        input = InputView.view(navigationController!.view, vc: self, delegate: self, project: project)
    }
    
    fileprivate func showInput() {
        if project.canEdit {
            input?.show()
            setBottomScrollInset(input?.frame.height ?? 0)
        }
    }
    
    fileprivate func hideInput() {
        input?.hide()
    }
    
    fileprivate func reloadAndCleanInput() {
        input?.clean()
        loadInitialPosts()
    }
    
    @objc fileprivate func openEdit() {
        performSegue(withIdentifier: "SegueToEdit", sender: nil)
    }
    
    fileprivate func delete(post: Post, cell: PostCell) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        Server.deletePost(post: post)
        { error in
            hud.hide(animated: true)
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                self.posts.remove(at: self.posts.index(of: post)!)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [self.tableView.indexPath(for: cell)!], with: .right)
                self.tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Pagination -
    
    fileprivate func addInfiniteScrolling() {
        tableView.addInfiniteScroll
        { tableView in
            self.loadMorePosts()
        }
    }
    
    @objc fileprivate func loadInitialPosts() {
        Server.getPosts(project: project)
        { error, posts in
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                self.addInitialPosts(posts: posts!)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func loadMorePosts() {
        Server.getPosts(project: project, skip: posts.count)
        { error, posts in
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                self.addPosts(posts: posts!)
            }
            self.tableView.finishInfiniteScroll()
        }
    }
    
    fileprivate func addInitialPosts(posts: [Post]) {
        let indexPathsToDelete = IndexPath.range(start: 0, length: self.posts.count)
        self.posts = posts
        let indexPathsToAdd = IndexPath.range(start: 0, length: posts.count)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPathsToDelete, with: .fade)
        tableView.insertRows(at: indexPathsToAdd, with: .fade)
        tableView.endUpdates()
    }
    
    fileprivate func addPosts(posts: [Post]) {
        let indexPaths = IndexPath.range(start: self.posts.count, length: posts.count)
        self.posts += posts
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .bottom)
        tableView.endUpdates()
    }
    
    // MARK: - Notifications -
    
    fileprivate func subcribeForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ProjectController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ProjectController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue))
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        input?.changeBottomSpacing(keyboardHeight)
        UIView.animate(withDuration: duration,
                                   delay: 0,
                                   options: options,
                                   animations: { 
                                    self.input?.layoutIfNeeded()
            }) { finished in }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue))
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        input?.changeBottomSpacing(0)
        UIView.animate(withDuration: duration,
                                   delay: 0,
                                   options: options,
                                   animations: {
                                    self.input?.layoutIfNeeded()
        }) { finished in }
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? NewProjectController {
            dvc.project = project
        }
    }
    
    // MARK: - Rotations -
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        needsHeaderViewLayout = true
        coordinator.animate(alongsideTransition: { context in
            self.checkHeaderViewHeight()
        }) { context in
            // Completion
        }
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
