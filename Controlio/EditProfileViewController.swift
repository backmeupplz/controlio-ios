//
//  EditProfileViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD

class EditProfileViewController: UITableViewController, EditProfileCellDelegate, PickerDelegate {

    // MARK: - Variables -
    
    var user: User!
    let imagePicker = UIImagePickerController()
    
    // MARK: - Actions -
    
    @IBAction func saveTouched(_ sender: AnyObject) {
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileCell
        var name = cell.nameTextfield.text
        if name?.isEmpty ?? false {
            name = nil
        }
        var phone = cell.phoneTextfield.text
        if phone?.isEmpty ?? false {
            phone = nil
        }
        
        if let tempPorfileImage = user.tempProfileImage {
            hud.mode = .annularDeterminate
            hud.label.text = "Uploading image"
            S3.uploadImage(tempPorfileImage, progress: { progress in
                print(progress)
                hud.progress = progress
            })
            { key, error in
                if let error = error {
                    PopupNotification.showNotification(error)
                } else {
                    Server.editProfile(name: name, phone: phone, profileImage: key)
                    { error in
                        if let error = error {
                            PopupNotification.showNotification(error.domain)
                        } else {
                            hud.hide(animated: true)
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        } else {
            hud.label.text = "Uploading data"
            Server.editProfile(name: name, phone: phone, profileImage: user.profileImageKey)
            { error in
                if let error = error {
                    PopupNotification.showNotification(error.domain)
                } else {
                    hud.hide(animated: true)
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        setupTableView()
        addRefreshControl()
        setupBackButton()
        setupImagePicker()
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell", for: indexPath) as! EditProfileCell
        cell.user = user
        cell.delegate = self
        return cell
    }
    
    // MARK: - EditProfileCellDelegate -
    
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
            self.user.profileImageKey = nil
            self.user.tempProfileImage = nil
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        { action in
            // do nothing
        }
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        if user.profileImageKey != nil || user.tempProfileImage != nil {
            alert.addAction(remove)
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            setNewPhoto(image: pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions -
    
    func loadData() {
        Server.getProfile
        { error, user in
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                self.user = user
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "EditProfileCell", bundle: nil), forCellReuseIdentifier: "EditProfileCell")
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProjectController.loadData), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    fileprivate func setNewPhoto(image: UIImage) {
        user.tempProfileImage = image
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileCell
        user.name = cell.nameTextfield.text
        user.phone = cell.phoneTextfield.text
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}
