//
//  NewProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD
import UITextField_Shake

class NewProjectController: UITableViewController, NewProjectCellDelegate, PickerDelegate {
    
    // MARK: - Variables -
    
    var project = Project()
    let imagePicker = ImagePicker()
    var cell: NewProjectCell!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectCell", for: indexPath) as! NewProjectCell
        cell.project = project
        cell.delegate = self
        return cell
    }

    // MARK: - NewProjectCellDelegate -
    
    func editPhotoTouched(sender: UIView) {
        let alert = UIAlertController(preferredStyle: .actionSheet, sourceView: sender)
        alert.add(action: NSLocalizedString("Choose from library", comment: "Open picker option"))
        {
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.add(action: NSLocalizedString("Take a photo", comment: "Open picker option"))
        {
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.addCancelButton()
        
        if project.tempImage != nil || project.imageKey != nil {
            alert.add(action: NSLocalizedString("Remove photo", comment: "Open picker option"))
            {
                self.project.tempImage = nil
                self.project.imageKey = nil
                self.reloadCell()
            }
        }
        present(alert, animated: true, completion: nil)
    }
    
    func choosePeopleTouched() {
        Router(self).showClients(with: project)
    }
    
    func createTouched() {
        view.endEditing(true)
        
        var allGood = true
        
        if project.title?.isEmpty ?? true {
            cell.titleTextField.shake()
            allGood = false
        }
        if cell.type == .client && !(project.tempManagerEmail?.isEmail ?? false) {
            cell.managerTextField.shake()
            allGood = false
        }
        
        if allGood {
            guard let hud = MBProgressHUD.show() else { return }
            if project.tempImage != nil {
                hud.mode = .annularDeterminate
                hud.detailsLabel.text = NSLocalizedString("Uploading image", comment: "hud title")
                Server.add(project: project, progress: { progress in
                    hud.progress = progress
                    if progress >= 1 {
                        hud.mode = .indeterminate
                        hud.detailsLabel.text = NSLocalizedString("Adding new project", comment: "hud title")
                    }
                })
                { error in
                    hud.hide(animated: true)
                    if let error = error {
                        self.snackbarController?.show(error: error.domain)
                    } else {
                        self.project = Project()
                        self.selectFirstTab()
                        self.notificationCreateProject(project: self.project)
                    }
                }
            } else {
                hud.detailsLabel.text = NSLocalizedString("Adding new project", comment: "hud title")
                Server.add(project: project, progress: { progress in })
                { error in
                    hud.hide(animated: true)
                    if let error = error {
                        self.snackbarController?.show(error: error.domain)
                    } else {
                        self.project = Project()
                        self.reloadCell()
                        self.selectFirstTab()
                        self.snackbarController?.show(text: NSLocalizedString("You have successfuly created a project", comment: "snackbar title"))
                        self.notificationCreateProject(project: self.project)
                    }
                }
            }
        }
    }
    
    // MARK: - NotificationCenter -
    
    func notificationCreateProject(project: Project) {
        post(notification: .projectCreated)
    }
    
    // MARK: - UIImagePickerControllerDelegate -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            project.tempImage = pickedImage
            reloadCell()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBackButton()
        setupImagePicker()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.register(UINib(nibName: "NewProjectCell", bundle: nil), forCellReuseIdentifier: "NewProjectCell")
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    fileprivate func selectFirstTab() {
        navigationController?.tabBarController?.selectedIndex = 0
    }
    
    fileprivate func reloadCell() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}
