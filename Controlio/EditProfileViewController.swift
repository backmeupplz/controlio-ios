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
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
        setupImagePicker()
    }
    
    // MARK: - Actions -
    
    @IBAction func saveTouched(_ sender: AnyObject) {
        view.endEditing(true)
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileCell
        
        var name = cell.nameTextfield.text
        if name?.isEmpty ?? false {
            name = nil
        }
        
        guard (name?.characters.count ?? 0) < 50 else {
            cell.nameTextfield.shake()
            snackbarController?.show(error: NSLocalizedString("Name should be less than 50 chars", comment: "snackbar error"))
            return
        }

        var phone = cell.phoneTextfield.text
        if phone?.isEmpty ?? false {
            phone = nil
        }
        
        guard (phone?.characters.count ?? 0) < 20 else {
            cell.phoneTextfield.shake()
            snackbarController?.show(error: NSLocalizedString("Phone should be less than 20 chars", comment: "snackbar error"))
            return
        }

        guard let hud = MBProgressHUD.show() else { return }
        
        if let tempPorfileImage = user.tempProfileImage {
            hud.mode = .annularDeterminate
            hud.label.text = NSLocalizedString("Uploading image", comment: "Edit profile upload message")
            S3.upload(image: tempPorfileImage, progress: { progress in
                hud.progress = progress
            })
            { key, error in
                if let error = error {
                    PopupNotification.show(notification: error)
                    hud.hide(animated: true)
                } else {
                    Server.editProfile(name: name, phone: phone, profileImage: key)
                    { error in
                        hud.hide(animated: true)
                        if let error = error {
                            self.snackbarController?.show(error: error.domain)
                        } else {
                            self.snackbarController?.show(text: NSLocalizedString("Your profile has been updated", comment: "snackbar message"))
                        }
                    }
                }
            }
        } else {
            hud.label.text = NSLocalizedString("Uploading data", comment: "Edit profile upload message")
            Server.editProfile(name: name, phone: phone, profileImage: user.profileImageKey)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.snackbarController?.show(text: NSLocalizedString("Your profile has been updated", comment: "snackbar message"))
                }
            }
        }
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
    
    func editPhotoTouched(sender: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        let library = UIAlertAction(title: NSLocalizedString("Choose from library", comment: "Open picker option"), style: .default)
        { action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let camera = UIAlertAction(title: NSLocalizedString("Take a photo", comment: "Open picker option"), style: .default)
        { action in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let remove = UIAlertAction(title: NSLocalizedString("Remove photo", comment: "Open picker option"), style: .destructive)
        { action in
            self.user.profileImageKey = nil
            self.user.tempProfileImage = nil
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Open picker option"), style: .cancel)
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
    
    func saveTouched() {
        saveTouched(self)
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
        self.refreshControl?.beginRefreshing()
        Server.getProfile
        { error, user in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
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
        refreshControl?.addTarget(self, action: #selector(EditProfileViewController.loadData), for: .valueChanged)
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
