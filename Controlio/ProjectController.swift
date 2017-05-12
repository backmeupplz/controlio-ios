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
import DZNEmptyDataSet
import NohanaImagePicker
import AsyncDisplayKit
import IQKeyboardManagerSwift
import Alamofire
import KeyboardObserver

protocol ProjectControllerDelegate: class {
    func didUpdate(project: Project)
}

class ProjectController: ASViewController<ASDisplayNode>, DZNEmptyDataSetDelegate {
    
    // MARK: - Variables -
    
    var delegate: ProjectControllerDelegate?
    var project: Project!
    var posts = [Post]()
    
    // MARK: - Private variables -
    
    fileprivate var tableNode: ASTableNode!
    
    fileprivate var input: InputView?
    fileprivate let imagePicker = NohanaImagePickerController()
    fileprivate let cameraPicker = UIImagePickerController()
    fileprivate let maxCountAttachments: Int = 10
    fileprivate var currentGallery: ImageGallery?
    
    fileprivate var isLoading = true
    fileprivate var needsMorePosts = false
    
    fileprivate var progressView: ProgressView?
    
    fileprivate var refreshControl: UIRefreshControl?
    
    fileprivate var progressRequest: DataRequest?
    
    fileprivate let keyboard = KeyboardObserver()
    
    // MARK: - View Controller Life Cycle -
    
    init(with project: Project, delegate: ProjectControllerDelegate? = nil) {
        let tableNode = ASTableNode(style: .plain)
        
        super.init(node: tableNode)
        
        self.delegate = delegate
        self.project = project
        self.tableNode = tableNode
        self.tableNode.dataSource = self
        self.tableNode.delegate = self
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
        setupBackButton()
        setupInfoButton()
        setupInput()
        setupProgressBar()
        loadInitialPosts()
        setupKeyboard()
        edgesForExtendedLayout = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        IQKeyboardManager.sharedManager().enable = false
        
        keyboard.enabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideInput()
        view.endEditing(true)
        IQKeyboardManager.sharedManager().enable = true
        
        keyboard.enabled = false
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configure() {
        title = project.title
        
        showInput()
        setupEmptyView()
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
        refreshControl.addTarget(self, action: #selector(ProjectController.loadInitialPosts), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupEmptyView() {
        self.tableNode.view.emptyDataSetDelegate = self
        self.tableNode.view.emptyDataSetSource = self
        self.tableNode.view.tableFooterView = UIView()
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
        let scrollIndicatorInsets = tableNode.view.scrollIndicatorInsets
        let contentInset = tableNode.view.contentInset
        tableNode.view.scrollIndicatorInsets = UIEdgeInsetsMake(scrollIndicatorInsets.top,
                                                           scrollIndicatorInsets.left,
                                                           inset,
                                                           scrollIndicatorInsets.right)
        tableNode.view.contentInset = UIEdgeInsetsMake(contentInset.top,
                                                  contentInset.left,
                                                  inset,
                                                  contentInset.right)
    }
    
    fileprivate func setupInput() {
        input = InputView.view(navigationController!.view, delegate: self, project: project)
    }
    
    fileprivate func setupProgressBar() {
        if project.progressEnabled {
            progressView = R.nib.progressView.firstView(owner: nil)
            progressView?.delegate = self
            progressView?.canEdit = project.canEdit
            progressView?.progress = project.progress
            tableNode.view.tableHeaderView = progressView
        } else {
            tableNode.view.tableHeaderView = nil
        }
    }
    
    fileprivate func showInput() {
        if project.canEdit && !project.isFinished {
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
        Server.deletePost(project: project, post: post)
        { error in
            hud.hide(animated: true)
            if let error = error {
                PopupNotification.show(notification: error.domain)
            } else {
                guard let index = self.posts.index(of: post) else { return }
                self.posts.remove(at: self.posts.index(of: post)!)
                self.tableNode.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
            }
        }
    }
    
    @objc fileprivate func openProject() {
        guard let hud = MBProgressHUD.show() else { return }
        hud.detailsLabel.text = NSLocalizedString("Getting project info...", comment: "Getting project message")
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
    
    fileprivate func isValidPost(text: String, attachments: [Any]) -> Bool {
        return !text.isEmpty || attachments.count > 0
    }
    
    fileprivate func filter(attachments: [Any]) -> (completedKeys: [String], imagesToUpload: [UIImage]) {
        let completedKeys = attachments.filter { $0 is String } as! [String]
        let imagesToUpload = attachments.filter { $0 is UIImage } as! [UIImage]
        return (completedKeys, imagesToUpload)
    }
    
    fileprivate func setupKeyboard() {
        keyboard.observe
        { [weak self] event in
            guard let s = self else { return }
            switch event.type {
            case .willShow, .willHide, .willChangeFrame:
                let distance = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
                let bottom = distance >= s.bottomLayoutGuide.length ? distance : s.bottomLayoutGuide.length
                
                s.input?.changeBottomSpacing(bottom)
                
                s.setBottomScrollInset((s.input?.frame.height ?? 0.0) + bottom)
                
                UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations:
                { [weak self] () -> Void in
                    guard let s = self else { return }
                    s.input?.superview?.layoutIfNeeded()
                }, completion: nil)
            default:
                break
            }
        }
    }
    
    // MARK: - Pagination -
    
    @objc fileprivate func loadInitialPosts() {
        isLoading = true
        Server.getPosts(for: project)
        { error, posts in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let posts = posts {
                self.isLoading = false
                self.addInitialPosts(posts: posts)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func loadMorePosts(completion: @escaping ()->()) {
        Server.getPosts(for: project, skip: posts.count)
        { error, posts in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else if let posts = posts {
                self.addPosts(posts: posts)
            }
            completion()
        }
    }
    
    fileprivate func addInitialPosts(posts: [Post]) {
        needsMorePosts = true
        self.posts = posts
        
        tableNode.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    fileprivate func addPosts(posts: [Post]) {
        if posts.count == 0 {
            needsMorePosts = false
        }
        let indexPaths = IndexPath.range(start: self.posts.count, length: posts.count)
        self.posts += posts
        
        tableNode.insertRows(at: indexPaths, with: .fade)
    }
    
    // MARK: - Notifications -
    
//    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
//        let userInfo = (notification as NSNotification).userInfo!
//        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
//        
//        let curveNumber = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue
//        let curve = UIViewAnimationCurve(rawValue: curveNumber)!
//        
//        let options = UIViewAnimationOptions(rawValue: curve)
//        let duration = TimeInterval(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
//        
//        input?.changeBottomSpacing(keyboardHeight)
//        UIView.animate(withDuration: duration,
//                                   delay: 0,
//                                   options: options,
//                                   animations: { 
//                                    self.input?.layoutIfNeeded()
//            }) { finished in }
//    }
//    
//    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
//        let userInfo = (notification as NSNotification).userInfo!
//        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue))
//        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
//        
//        input?.changeBottomSpacing(0)
//        UIView.animate(withDuration: duration,
//                                   delay: 0,
//                                   options: options,
//                                   animations: {
//                                    self.input?.layoutIfNeeded()
//        }) { finished in }
//    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension ProjectController: PostCellDelegate {
    func openAttachment(at index: Int, post: Post, fromView: UIView) {
        currentGallery = ImageGallery()
        currentGallery?.showGallery(atViewController: self, index: index, imageKeys: post.attachments, fromView: fromView)
    }
    
    func edit(post: Post, cell: PostCell) {
        guard project.canEdit else {
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.add(sourceView: cell.view)
        if post.author.id == Server.currentUser?.id {
            alert.add(action: NSLocalizedString("Edit", comment: "Edit post button"))
            {
                self.input?.post = post
            }
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
        hud.detailsLabel.text = NSLocalizedString("Getting user profile...", comment: "getting user profile hud message")
        
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
}

extension ProjectController: InputViewDelegate {
    func openPicker(with delegate: AllPickerDelegate, sender: UIView) {
        imagePicker.delegate = delegate
        cameraPicker.delegate = delegate
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.add(sourceView: sender)
        
        alert.add(action: NSLocalizedString("Camera", comment: "Image picker button"))
        {
            self.cameraPicker.sourceType = .camera
            self.cameraPicker.allowsEditing = false
            self.present(self.cameraPicker, animated: true, completion: nil)
        }
        alert.add(action: NSLocalizedString("Library", comment: "Image picker button"))
        {
            let count = self.input?.attachmentCount ?? 0
            self.imagePicker.maximumNumberOfSelection = self.maxCountAttachments - count
            self.imagePicker.dropAll()
            self.imagePicker.delegate = delegate
            self.present(self.imagePicker, animated: true){}
        }
        alert.addCancelButton()
        
        present(alert, animated: true) { }
    }
    
    func closeImagePicker() {
        dismiss(animated: true) { }
    }
    
    func shouldChangeStatus(text: String) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.detailsLabel.text = NSLocalizedString("Changing status...", comment: "project change status message")
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
                self.snackbarController?.show(text: NSLocalizedString("Status has been changed", comment: "project chande status success message"))
            }
        }
    }
    
    func addPost(text: String?, keys: [String]?, hud: MBProgressHUD){
        hud.mode = .indeterminate
        hud.detailsLabel.text = NSLocalizedString("Uploading new message...", comment: "new post upload message")
        Server.addPost(to: self.project, text: text!, attachmentKeys: keys!)
        { error, post in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.project.lastPost = post
                self.configure()
                self.reloadAndCleanInput()
                self.snackbarController?.show(text: NSLocalizedString("Message sent", comment: "new post upload success message"))
            }
        }
    }
    
    func shouldAddPost(text: String, attachments: [Any]) {
        guard isValidPost(text: text, attachments: attachments) else {
            snackbarController?.show(error: NSLocalizedString("Please provide at least one attachment or text", comment: "new post error"))
            return
        }
        guard let hud = MBProgressHUD.show() else { return }
        let (completedKeys, imagesToUpload) = filter(attachments: attachments)
        
        if imagesToUpload.count > 0 {
            hud.mode = .annularDeterminate
            hud.detailsLabel.text = NSLocalizedString("Uploading attachments...", comment: "new post upload message")
            S3.upload(images: imagesToUpload, progress:
                { progress in
                    hud.progress = progress
            })
            { keys, error in
                if let error = error {
                    self.snackbarController?.show(error: error)
                    hud.hide(animated: true)
                } else if let keys = keys {
                    self.addPost(text: text, keys: keys+completedKeys, hud: hud)
                }
            }
        } else {
            self.addPost(text: text, keys: completedKeys, hud: hud)
        }
    }
    
    func updateViewPost(post: Post){
        tableNode.reloadRows(at: [IndexPath(row: self.posts.index(of: post)!, section: 0)], with: .fade)
    }
    
    func editPost(post: Post, hud: MBProgressHUD){
        hud.mode = .indeterminate
        hud.detailsLabel.text = NSLocalizedString("Uploading data", comment: "edit post upload message")
        Server.editPost(project: self.project, post: post, text: post.text ?? "", attachments: post.attachments)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.input?.post = nil
                self.snackbarController?.show(text: post.type == .status ? NSLocalizedString("Status changed", comment: "edit post success message"): NSLocalizedString("Message changed", comment: "edit post success message"))
                self.updateViewPost(post: post)
            }
        }
    }
    
    func shouldEditPost(post: Post, text: String, attachments: [Any]) {
        guard isValidPost(text: text, attachments: attachments) else {
            self.snackbarController?.show(error: NSLocalizedString("Please provide at least one attachment or text", comment: "New post error"))
            return
        }
        guard let hud = MBProgressHUD.show() else { return }
        let (completedKeys, imagesToUpload) = filter(attachments: attachments)
        
        if imagesToUpload.count > 0 {
            hud.mode = .annularDeterminate
            hud.detailsLabel.text = NSLocalizedString("Uploading attachments", comment: "Edit post upload message")
            S3.upload(images: imagesToUpload, progress:
                { progress in
                    hud.progress = progress
            })
            { keys, error in
                if let error = error {
                    self.snackbarController?.show(error: error)
                    hud.hide(animated: true)
                } else {
                    post.text = text
                    post.attachments = keys!+completedKeys
                    self.editPost(post: post, hud: hud)
                }
            }
        } else {
            post.text = text
            post.attachments = completedKeys
            editPost(post: post, hud: hud)
        }
    }
}

extension ProjectController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = isLoading ? NSLocalizedString("Loading...", comment: "empty view placeholder"): NSLocalizedString("No posts yet", comment: "empty view placeholder")
        let attributes = [
            NSFontAttributeName: Font.boldSystemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: Color.darkGray
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = isLoading ? NSLocalizedString("Let us get your posts from the cloud", comment: "empty view placeholder") : project.canEdit ? NSLocalizedString("Please create your first update", comment: "empty view placeholder") : NSLocalizedString("Managers should post updates here", comment: "empty view placeholder")
        
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
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

extension ProjectController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            return PostCell(with: self.posts[indexPath.row], delegate: self)
        }
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return needsMorePosts
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        loadMorePosts
        {
            context.completeBatchFetching(true)
        }
    }
}

extension ProjectController: ProgressViewDelegate {
    func progressViewChanged(value: Int) {
        progressRequest?.cancel()
        progressRequest = Server.update(progress: value, project: project)
        { error in
            if error == nil {
                self.project.progress = value
                self.delegate?.didUpdate(project: self.project)
            }
        }
    }
}
