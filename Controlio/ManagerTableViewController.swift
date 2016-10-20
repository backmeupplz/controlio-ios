//
//  ManagerTableViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 21/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol ManagerTableViewControllerDelegate: class {
    func didChoose(manager: User)
}

enum ManagerTableViewControllerType {
    case choose, show
    func viewControllerTitle() -> String {
        switch self {
        case .choose:
            return NSLocalizedString("Choose a Manager", comment: "Managers VC type option")
        case .show:
            return NSLocalizedString("All managers", comment: "Managers VC type option")
        }
    }
}

class ManagerTableViewController: UITableViewController {
    
    // MARK: - Variables -
    
    var delegate: ManagerTableViewControllerDelegate?
    var type = ManagerTableViewControllerType.choose
    var managers = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Outlets -
    
    @IBAction func addTouched(_ sender: AnyObject) {
        performSegue(withIdentifier: "SegueToNewManager", sender: self)
    }
    
    // MARK: - View Controller Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupTableView()
        addRefreshControl()
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    // MARK: - UITableViewDataSource -

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return managers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.user = managers[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didChoose(manager: managers[indexPath.row])
        let _ = navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        Server.removeManager(user: managers[indexPath.row])
        { error in
            hud.hide(animated: true)
            if let error = error {
                PopupNotification.show(notification: error.domain)
            } else {
                self.tableView.beginUpdates()
                self.managers.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Functions -
    
    func loadData() {
        refreshControl?.beginRefreshing()
        Server.getManagers
        { error, users in
            if let error = error {
                PopupNotification.show(notification: error.domain)
            } else {
                self.managers = users!
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupNavigationItem() {
        navigationItem.title = type.viewControllerTitle()
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ManagerTableViewController.loadData), for: .valueChanged)
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
