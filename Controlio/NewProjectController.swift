//
//  NewProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD

class NewProjectController: UITableViewController, NewProjectCellDelegate, PickerDelegate {
    
    // MARK: - Variables -
    
    var project = Project()
    let imagePicker = UIImagePickerController()
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectCell", for: indexPath) as! NewProjectCell
        cell.project = project
        cell.delegate = self
        return cell
    }

    // MARK: - NewProjectCellDelegate -
    
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
            self.project.tempImage = nil
            self.project.imageKey = nil
            self.reloadCell()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Open picker option"), style: .cancel)
        { action in
            // do nothing
        }
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        if project.tempImage != nil || project.imageKey != nil {
            alert.addAction(remove)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func choosePeopleTouched() {
        Router(self).showClients(with: project)
    }
    
    func createTouched() {
        print("Should create project")
        reloadCell()
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
