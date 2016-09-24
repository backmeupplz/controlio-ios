//
//  AddManagerViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD

class AddManagerViewController: UITableViewController {

    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }

    // MARK: - UITableViewDataSource -

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AddManagerCell", for: indexPath)
    }
    
    // MARK: - Actions -
    
    @IBAction func saveTouched(_ sender: AnyObject) {
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddManagerCell
        cell.emailTextfield.resignFirstResponder()
        Server.addManager(email: cell.emailTextfield.text ?? "")
        { error in
            hud.hide(animated: true)
            if let error = error {
                PopupNotification.showNotification(error.domain)
            } else {
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "AddManagerCell", bundle: nil), forCellReuseIdentifier: "AddManagerCell")
    }

}
