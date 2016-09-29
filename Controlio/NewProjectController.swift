//
//  NewProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import CLTokenInputView
import MBProgressHUD

class NewProjectController: UITableViewController, NewProjectCellDelegate, ManagerTableViewControllerDelegate, PickerDelegate {
    
    // MARK: - Variables -
    
    var manager: User?
    let imagePicker = UIImagePickerController()
    
    fileprivate var image: UIImage?
    fileprivate var tempTitle: String?
    fileprivate var tempInitialStatus: String?
    fileprivate var tempDescription: String?
    fileprivate var tempTokens = [CLToken]()
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectCell", for: indexPath) as! NewProjectCell
        configure(cell: cell)
        return cell
    }

    // MARK: - NewProjectCellDelegate -
    
    func editPhotoTouched() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "Choose from library", style: .default)
        { action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let camera = UIAlertAction(title: "Take a photo", style: .default)
        { action in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let remove = UIAlertAction(title: "Remove photo", style: .destructive)
        { action in
            self.image = nil
            self.reloadCell()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        { action in
            // do nothing
        }
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        if image != nil {
            alert.addAction(remove)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func chooseManagerTouched() {
        performSegue(withIdentifier: "SegueToChooseManager", sender: nil)
    }
    
    func createTouched() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NewProjectCell
        
        guard let image = image else {
            PopupNotification.showNotification("Please provide an image")
            return
        }
        guard let title = cell.titleTextField.text, !title.isEmpty else {
            PopupNotification.showNotification("Please provide a title")
            return
        }
        guard let initialStatus = cell.initialStatusTextField.text, !initialStatus.isEmpty else {
            PopupNotification.showNotification("Please provide an initial status")
            return
        }
        guard let description = cell.descriptionTextField.text, !description.isEmpty else {
            PopupNotification.showNotification("Please provide a description")
            return
        }
        guard cell.clientEmailsTokenView.allTokens.count > 0 else {
            PopupNotification.showNotification("Please provide at least one client email")
            return
        }
        guard let manager = manager else {
            PopupNotification.showNotification("Please choose a manager")
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        hud.mode = .annularDeterminate
        hud.label.text = "Uploading image"
        S3.uploadImage(image, progress: { progress in
            hud.progress = progress
        })
        { key, error in
            if let error = error {
                PopupNotification.showNotification(error)
                hud.hide(animated: true)
            } else {
                Server.addProject(image: key!, title: title, initialStatus: initialStatus, clients: cell.clientEmailsTokenView.allTokens, description: description, manager: manager)
                { error in
                    if let error = error {
                        PopupNotification.showNotification(error.domain)
                        hud.hide(animated: true)
                    } else {
                        hud.hide(animated: true)
                        self.cleanTempFields()
                        self.selectFirstTab()
                    }
                }
            }
        }
    }
    
    // MARK: - ManagerTableViewControllerDelegate -
    
    func didChoose(manager: User) {
        self.manager = manager
    }
    
    // MARK: - UIImagePickerControllerDelegate -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            setNewPhoto(image: pickedImage)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCell()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configure(cell: NewProjectCell) {
        cell.delegate = self
        cell.managerPhotoImage.image = UIImage(named: "photo-background-placeholder")
        if let manager = manager {
            cell.managerPhotoImage.load(key: manager.profileImageKey)
            cell.managerTitleLabel.isHidden = false
            cell.managerTitleLabel.text = manager.name ?? manager.email
            cell.chooseManagerButton.isHidden = true
            cell.chooseManagerBackgroundButton.isHidden = false
        } else {
            cell.managerTitleLabel.isHidden = true
            cell.managerTitleLabel.text = nil
            cell.chooseManagerButton.isHidden = false
            cell.chooseManagerBackgroundButton.isHidden = true
        }
        if let image = image {
            cell.photoImage.image = image
            cell.cameraImage.isHidden = true
            cell.photoLabel.text = "Edit image"
        } else {
            cell.photoImage.image = UIImage(named: "photo-background-placeholder")
            cell.cameraImage.isHidden = false
            cell.photoLabel.text = "Add image"
        }
        
        cell.titleTextField.text = tempTitle
        cell.initialStatusTextField.text = tempInitialStatus
        cell.descriptionTextField.text = tempDescription
        for token in cell.clientEmailsTokenView.allTokens {
            cell.clientEmailsTokenView.remove(token)
        }
        for token in tempTokens {
            cell.clientEmailsTokenView.add(token)
        }
    }
    
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
    
    fileprivate func setNewPhoto(image: UIImage) {
        self.image = image
        
        reloadCell()
    }
    
    fileprivate func reloadCell() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NewProjectCell
        
        tempTitle = cell.titleTextField.text
        tempInitialStatus = cell.initialStatusTextField.text
        tempDescription = cell.descriptionTextField.text
        tempTokens = cell.clientEmailsTokenView.allTokens
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    fileprivate func cleanTempFields() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NewProjectCell
        image = nil
        tempTitle = nil
        tempInitialStatus = nil
        tempDescription = nil
        tempTokens = [CLToken]()
        manager = nil
        cell.titleTextField.text = nil
        cell.initialStatusTextField.text = nil
        cell.descriptionTextField.text = nil
        for token in cell.clientEmailsTokenView.allTokens {
            cell.clientEmailsTokenView.remove(token)
        }
        reloadCell()
    }
    
    fileprivate func selectFirstTab() {
        navigationController?.tabBarController?.selectedIndex = 0
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        if let vc = dest as? ManagerTableViewController {
            vc.delegate = self
            vc.type = .choose
        }
    }
}
