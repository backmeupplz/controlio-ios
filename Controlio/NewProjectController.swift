//
//  NewProjectController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class NewProjectController: UITableViewController, NewProjectCellDelegate, ManagerTableViewControllerDelegate {
    
    // MARK: - Variables -
    
    var manager: User?
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectCell", for: indexPath) as! NewProjectCell
        cell.delegate = self
        configure(cell: cell)
        return cell
    }

    // MARK: - NewProjectCellDelegate -
    
    func editPhotoTouched() {
        print("edit photo")
    }
    
    func chooseManagerTouched() {
        performSegue(withIdentifier: "SegueToChooseManager", sender: nil)
    }
    
    func createTouched() {
        print("create")
    }
    
    // MARK: - ManagerTableViewControllerDelegate -
    
    func didChoose(manager: User) {
        self.manager = manager
    }
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configure(cell: NewProjectCell) {
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
    }
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.register(UINib(nibName: "NewProjectCell", bundle: nil), forCellReuseIdentifier: "NewProjectCell")
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
