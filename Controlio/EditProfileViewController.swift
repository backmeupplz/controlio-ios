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
    var initUser: User!
    let imagePicker = UIImagePickerController()
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUser = user.copy()
        
        setupTableView()
        addRefreshControl()
        setupImagePicker()
        
    }
    
    // MARK: - Actions -
    
    @IBAction func saveTouched(_ sender: AnyObject) {
        save(completion: nil)
    }
    
    func back(sender: UIBarButtonItem){
        
        let (_, name, phone) = formData()
        
        initUser.name = name
        initUser.phone = phone
        
        if user.equals(compareTo: initUser) {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        let alert = UIAlertController(title:"You have unsaved data", message: "Would you like to discard it?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title:"Discard", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title:"Save", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            self.save(completion: { error in
                _ = self.navigationController?.popViewController(animated: true)
            })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func formData() ->(cell: EditProfileCell, name: String?, phone: String?) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileCell
        
        var name = cell.nameTextfield.text
        if name?.isEmpty ?? false {
            name = nil
        }
        
        var phone = cell.phoneTextfield.text
        if phone?.isEmpty ?? false {
            phone = nil
        }
        
        return (cell, name, phone)
    }
    
    func save(completion:((NSError?)->())!){
        view.endEditing(true)

        let (cell, name, phone) = formData()
        
        guard (name?.characters.count ?? 0) < 50 else {
            cell.nameTextfield.shake()
            snackbarController?.show(error: "Name should be less than 50 chars")
            return
        }
        
        guard (phone?.characters.count ?? 0) < 20 else {
            cell.phoneTextfield.shake()
            snackbarController?.show(error: "Phone should be less than 20 chars")
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
                            completion(error)
                        } else {
                            self.snackbarController?.show(text: "Your profile has been updated")
                            completion(nil)
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
                    completion(error)
                } else {
                    self.snackbarController?.show(text: "Your profile has been updated")
                    completion(nil)
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
                self.initUser = user
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Private functions -
    
    fileprivate func setupBackButton(){
        self.navigationItem.hidesBackButton = true
        let image = UIImage(named:"back_button") as UIImage!
        let btnBack:UIButton = UIButton.init(type: .custom)
        btnBack.addTarget(self, action: #selector(EditProfileViewController.back(sender:)), for: .touchUpInside)
        btnBack.setImage(image, for: .normal)
        btnBack.setTitleColor(UIColor.blue, for: .normal)
        btnBack.sizeToFit()
        let backButton:UIBarButtonItem = UIBarButtonItem(customView: btnBack)
        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
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
