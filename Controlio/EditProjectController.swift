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
import NohanaImagePicker
import Photos

class EditProjectController: UITableViewController, EditProjectCellDelegate, PickerDelegate {

    // MARK: - NohanaImagePickerControllerDelegate -
    
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController){
        print("cancel")
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts: [PHAsset]){
        print("complited")
        if let image = pickedAssts.first {
            project.tempImage = picker.getAssetUIImage(image)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Variables -
    
    var project = Project()
    let imagePicker = NohanaImagePickerController()
    var cell: EditProjectCell!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.present(self.imagePicker, animated: true, completion: nil)
        }
//        alert.add(action: NSLocalizedString("Take a photo", comment: "Open picker option"))
//        {
//            self.imagePicker.sourceType = .camera
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
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
    
    func save(project: Project) {
        view.endEditing(true)
        
        var allGood = true
        
        if (project.title?.isEmpty ?? true) && (project.tempTitle?.isEmpty ?? true) {
            cell.titleTextField.shake()
            allGood = false
        }
        
        if allGood {
            guard let hud = MBProgressHUD.show() else { return }
            if project.tempImage != nil {
                hud.mode = .annularDeterminate
                hud.label.text = "Uploading image"
                Server.edit(project: project, progress: { progress in
                    hud.progress = progress
                    if progress >= 1 {
                        hud.mode = .indeterminate
                        hud.label.text = "Editing the project..."
                    }
                })
                { error in
                    hud.hide(animated: true)
                    if let error = error {
                        self.snackbarController?.show(error: error.domain)
                    } else {
                        self.snackbarController?.show(text: "Project info has been changed")
                    }
                }
            } else {
                
                hud.label.text = "Editing the project..."
                Server.edit(project: project, progress: { progress in })
                { error in
                    
                    hud.hide(animated: true)
                    if let error = error {
                        self.snackbarController?.show(error: error.domain)
                    } else {
                        self.snackbarController?.show(text: "Project info has been changed")
                    }
                }
            }
        }
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
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.register(UINib(nibName: "EditProjectCell", bundle: nil), forCellReuseIdentifier: "EditProjectCell")
    }
    
    fileprivate func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.maximumNumberOfSelection = 1
    }
    
    fileprivate func reloadCell() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}
