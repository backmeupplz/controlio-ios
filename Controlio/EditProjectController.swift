//
//  EditProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 01/02/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD
import UITextField_Shake

class EditProjectController: UITableViewController, EditProjectCellDelegate, PickerDelegate {

    // MARK: - Variables -
    
    var project: Project!
    var initProject: Project!
    let imagePicker = UIImagePickerController()
    var cell: EditProjectCell!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initProject = project.copy()
        setupBackButton()
        setupTableView()
        setupImagePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - EditProjectCellDelegate -
    
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
    
    func backTouched() {
        if project.isEqual(to: initProject) {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        let alert = UIAlertController(title: NSLocalizedString("You have unsaved data", comment: "alert title"), message: NSLocalizedString("Would you like to discard it?", comment: "alert message"), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.add(action: NSLocalizedString("Discard", comment: "alert button"), style: .destructive)
        {
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        alert.addCancelButton()
        
        present(alert, animated: true, completion: nil)
    }
    
    func save(project: Project) {
        view.endEditing(true)
        
        var allGood = true
        
        if project.title?.isEmpty ?? true {
            cell.titleTextField.shake()
            allGood = false
        }
        
        if allGood {
            guard let hud = MBProgressHUD.show() else { return }
            if project.tempImage != nil {
                hud.mode = .annularDeterminate
                hud.detailsLabel.text = NSLocalizedString("Uploading image", comment: "hud title")
                Server.edit(project: project, progress: { progress in
                    hud.progress = progress
                    if progress >= 1 {
                        hud.mode = .indeterminate
                        hud.detailsLabel.text = NSLocalizedString("Editing the project...", comment: "hud title")
                    }
                })
                { error, key in
                    hud.hide(animated: true)
                    if let error = error {
                        self.snackbarController?.show(error: error.domain)
                    } else {
                        self.project.imageKey = key
                        self.initProject = self.project.copy()
                        self.snackbarController?.show(text: "Project info has been changed")
                    }
                }
            } else {
                hud.detailsLabel.text = NSLocalizedString("Editing the project...", comment: "hud title")
                Server.edit(project: project, progress: { progress in })
                { error, key in
                    hud.hide(animated: true)
                    if let error = error {
                        self.snackbarController?.show(error: error.domain)
                    } else {
                        self.project.imageKey = key
                        self.initProject = self.project.copy()
                        self.snackbarController?.show(text: "Project info has been changed")
                    }
                }
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            project.tempImage = pickedImage
            reloadCell()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "EditProjectCell", for: indexPath) as! EditProjectCell
        cell.project = project
        cell.delegate = self
        return cell
    }
    
    // MARK: - Private Functions -
    
    fileprivate func setupBackButton(){
        navigationItem.hidesBackButton = true
        let btnBack = CustomButton(type: .custom)
        btnBack.addTarget(self, action: #selector(EditProjectController.backTouched), for: .touchUpInside)
        btnBack.setImage(R.image.back_button(), for: .normal)
        btnBack.setTitleColor(UIColor.blue, for: .normal)
        btnBack.sizeToFit()
        btnBack.adjustsImageWhenHighlighted = false
        let backButton = UIBarButtonItem(customView: btnBack)
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.register(UINib(nibName: "EditProjectCell", bundle: nil), forCellReuseIdentifier: "EditProjectCell")
    }
    
    fileprivate func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    fileprivate func reloadCell() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}
