//
//  ProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD
import Material

class ProjectController: UITableViewController, PostCellDelegate, InputViewDelegate {
    
    // MARK: - Variables -
    
    var project: Project!
    var posts = [Post]()
    
    // MARK: - Private Variables -
    
    fileprivate var input: InputView?
    fileprivate let imagePicker = UIImagePickerController()
    
    fileprivate var currentGallery: ImageGallery?
    
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
        alert.add(sourceView: cell)
        alert.add(action: NSLocalizedString("Edit", comment: "Edit post button"))
        {
            self.input?.post = post
        }
        alert.add(action: NSLocalizedString("Delete", comment: "Edit post button"), style: .destructive)
        {
            self.delete(post: post, cell: cell)
        }
        alert.addCancelButton()
        
        present(alert, animated: true, completion: nil)
    }
    
    func open(user: User) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = "Getting user profile..."
        
        Server.getProfile(for: user)
        { error, user in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let user = user {
                Router(self).show(user: user)
            }
        }
    }
    
    // MARK: - InputViewDelegate -
    
    func openPicker(with delegate: PickerDelegate, sender: UIView) {
        imagePicker.allowsEditing = false
        imagePicker.delegate = delegate
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.add(sourceView: sender)
        
        alert.add(action: NSLocalizedString("Camera", comment: "Image picker button"))
        {
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.add(action: NSLocalizedString("Library", comment: "Image picker button"))
        {
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.addCancelButton()
        
        present(alert, animated: true) { }
    }
    
    func closeImagePicker() {
        dismiss(animated: true) { }
    }
    
    func shouldAddPost(text: String, attachments: [Any]) {
        if text.isEmpty && attachments.count <= 0 {
            self.snackbarController?.show(error: NSLocalizedString("Please provide at least one attachment or text", comment: "New post error"))
            return
        }
        
        guard let hud = MBProgressHUD.show() else { return }
        
        let completedKeys = attachments.filter { $0 is String } as! [String]
        let imagesToUpload = attachments.filter { $0 is UIImage } as! [UIImage]
        
        if imagesToUpload.count > 0 {
            hud.mode = .annularDeterminate
            hud.label.text = NSLocalizedString("Uploading attachments...", comment: "New post upload message")
            S3.upload(images: imagesToUpload, progress:
            { progress in
                hud.progress = progress
            })
            { keys, error in
                if let error = error {
                    self.snackbarController?.show(error: error)
                    hud.hide(animated: true)
                } else {
                    hud.mode = .indeterminate
                    hud.label.text = NSLocalizedString("Uploading new message...", comment: "New post upload message")
                    Server.addPost(to: self.project, text: text, attachmentKeys: keys!+completedKeys)
                    { error, post in
                        hud.hide(animated: true)
                        if let error = error {
                            self.snackbarController?.show(error: error.domain)
                        } else {
                            self.project.lastPost = post
                            self.configure()
                            self.reloadAndCleanInput()
                            self.snackbarController?.show(text: "Message sent")
                        }
                    }
                }
            }
        } else {
            hud.mode = .indeterminate
            hud.label.text = NSLocalizedString("Uploading new message...", comment: "New post upload message")
            Server.addPost(to: project, text: text, attachmentKeys: completedKeys)
            { error, post in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.project.lastPost = post
                    self.configure()
                    self.reloadAndCleanInput()
                    self.snackbarController?.show(text: "Message sent")
                }
            }
        }
    }
    
    func shouldChangeStatus(text: String) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = NSLocalizedString("Changing status...", comment: "Project change status message")
        Server.change(status: text, project: project)
        { error, status in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.project.lastStatus = status
                self.project.lastPost = status
                self.configure()
                self.reloadAndCleanInput()
                self.snackbarController?.show(text: "Status has been changed")
            }
        }
    }
    
    func shouldEditPost(post: Post, text: String, attachments: [Any]) {
//        if text.isEmpty && attachments.count <= 0 {
//            PopupNotification.show(notification: NSLocalizedString("Please provide at least one attachment or text", comment: "Edit post error"))
//            return
//        }
//        
//        let hud = MBProgressHUD.showAdded(to: view, animated: false)
//        
//        let completedKeys = attachments.filter { $0 is String } as! [String]
//        let imagesToUpload = attachments.filter { $0 is UIImage } as! [UIImage]
//        
//        if imagesToUpload.count > 0 {
//            hud.mode = .annularDeterminate
//            hud.label.text = NSLocalizedString("Uploading attachments", comment: "Edit post upload message")
//            S3.upload(images: imagesToUpload, progress:
//                { progress in
//                    hud.progress = progress
//                })
//            { keys, error in
//                if let error = error {
//                    PopupNotification.show(notification: error)
//                    hud.hide(animated: true)
//                } else {
//                    hud.mode = .indeterminate
//                    hud.label.text = NSLocalizedString("Uploading data", comment: "Edit post upload message")
//                    Server.editPost(post: post, text: text, attachments: keys!+completedKeys)
//                    { error in
//                        hud.hide(animated: true)
//                        if let error = error {
//                            PopupNotification.show(notification: error.domain)
//                        } else {
//                            self.input?.post = nil
//                            post.text = text
//                            post.attachments = keys!+completedKeys
//                            self.tableView.beginUpdates()
//                            self.tableView.reloadRows(at: [IndexPath(row: self.posts.index(of: post)!, section: 0)], with: .fade)
//                            self.tableView.endUpdates()
//                        }
//                    }
//                }
//            }
//        } else {
//            hud.mode = .indeterminate
//            hud.label.text = NSLocalizedString("Uploading data", comment: "Edit post upload message")
//            Server.editPost(post: post, text: text, attachments: completedKeys)
//            { error in
//                hud.hide(animated: true)
//                if let error = error {
//                    PopupNotification.show(notification: error.domain)
//                } else {
//                    self.input?.post = nil
//                    post.text = text
//                    post.attachments = completedKeys
//                    self.tableView.beginUpdates()
//                    self.tableView.reloadRows(at: [IndexPath(row: self.posts.index(of: post)!, section: 0)], with: .fade)
//                    self.tableView.endUpdates()
//                }
//            }
//        }
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
        setupBackButton()
        setupInfoButton()
        setupInput()
        
        addInfiniteScrolling()
        loadInitialPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        subcribeForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotifications()
        hideInput()
        view.endEditing(true)
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configure() {
        title = project.title
        
        tableView.reloadData()
        showInput()
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
    
    fileprivate func setupInfoButton() {
        var customView: UIView!
        if let imageKey = project.imageKey {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imageView.backgroundColor = Color.white
            imageView.cornerRadius = 6
            imageView.load(key: imageKey)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            container.addSubview(imageView)
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.addTarget(self, action: #selector(ProjectController.openProject), for: .touchUpInside)
            container.addSubview(button)
            customView = container
        } else {
            let button = UIButton(type: .infoLight)
            button.addTarget(self, action: #selector(ProjectController.openProject), for: .touchUpInside)
            customView = button
        }
        let barItem = UIBarButtonItem(customView: customView)
        navigationItem.rightBarButtonItem = barItem
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
        if project.canEdit && !project.isArchived {
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
    
    fileprivate func delete(post: Post, cell: PostCell) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        Server.deletePost(post: post)
        { error in
            hud.hide(animated: true)
            if let error = error {
                PopupNotification.show(notification: error.domain)
            } else {
                self.posts.remove(at: self.posts.index(of: post)!)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [self.tableView.indexPath(for: cell)!], with: .right)
                self.tableView.endUpdates()
            }
        }
    }
    
    @objc fileprivate func openProject() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = NSLocalizedString("Getting project info...", comment: "Getting project message")
        Server.get(project: project)
        { error, project in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let project = project {
                Router(self).showInfo(for: project)
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
        Server.getPosts(for: project)
        { error, posts in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.addInitialPosts(posts: posts!)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func loadMorePosts() {
        Server.getPosts(for: project, skip: posts.count)
        { error, posts in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
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
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
