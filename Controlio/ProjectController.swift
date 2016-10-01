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
    
    func openAttachment(_ index: Int, post: Post) {
        print("open attachment: \(index)")
    }
    
    // MARK: - InputViewDelegate -
    
    func openPickerWithDelegate(_ delegate: PickerDelegate) {
        imagePicker.allowsEditing = false
        imagePicker.delegate = delegate
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
    
    func didTouchSend() {
        let text = input?.textView.text ?? ""
        let attachments = input?.attachmentContainerView.wrapperView.attachments ?? []
        
        if text.isEmpty && attachments.count <= 0 {
            PopupNotification.showNotification("Please provide at least one attachment or text")
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        hud.offset = CGPoint(x: 0, y: -MBProgressMaxOffset + 150)
        if attachments.count > 0 {
            hud.mode = .annularDeterminate
            hud.label.text = "Uploading attachments"
            S3.upload(images: attachments, progress:
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
                    Server.addPost(projectId: self.project.id, text: text, attachmentKeys: keys!)
                    { error in
                        if let error = error {
                            PopupNotification.showNotification(error.domain)
                            hud.hide(animated: true)
                        } else {
                            hud.hide(animated: true)
                            self.didAddProject()
                        }
                    }
                }
            }
        } else {
            hud.mode = .indeterminate
            hud.label.text = "Uploading data"
            Server.addPost(projectId: project.id, text: text, attachmentKeys: [])
            { error in
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                    hud.hide(animated: true)
                } else {
                    hud.hide(animated: true)
                    self.didAddProject()
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
        setupInput()
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
    
    // MARK: - Public Functions -
    
    func loadData() {
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configure() {
        title = project.title
        
        projectImageView.load(key: project.imageKey)
        statusLabel.text = project.status
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
        refreshControl?.addTarget(self, action: #selector(ProjectController.loadData), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        input = InputView.view(navigationController!.view, vc: self, delegate: self)
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
    
    fileprivate func didAddProject() {
        input?.textView.text = ""
        input?.attachmentContainerView.wrapperView.attachments = []
        loadData()
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
