//
//  UserViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 31/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MessageUI

class UserViewController: UITableViewController, UserProfileCellDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Variables -
    
    var user: User!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addRefreshControl()
    }
    
    // MARK: - MFMailComposeViewControllerDelegate -
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
    
    // MARK: - UserProfileCellDelegate -
    
    func phoneTouched(for user: User) {
        guard let phone = user.phone,
            !phone.isEmpty else {
            snackbarController?.show(error: "Wrong phone format")
            return
        }
        let number = String(phone.characters.filter {![" ", "\t", "\n"].contains($0)})
        
        guard let url = URL(string: "tel://\(number)") else {
            snackbarController?.show(error: "Wrong phone format")
            return
        }
        
        if !UIApplication.shared.canOpenURL(url) {
            snackbarController?.show(error: "Cannot make calls on this device")
            return
        }
        
        let alert = UIAlertController(title: phone, message: "Call this number?", preferredStyle: .alert)
        alert.add(action: "Call") {
            UIApplication.shared.open(url)
        }
        alert.addCancelButton()
        present(alert, animated: true) { }
    }
    
    func emailTouched(for user: User) {
        guard let email = user.email,
            email.isEmail else {
            snackbarController?.show(error: "Wrong email format")
            return
        }
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            present(mail, animated: true)
        } else {
            snackbarController?.show(error: "Cannot send mail on this device")
        }
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell", for: indexPath) as! UserProfileCell
        cell.user = user
        cell.delegate = self
        return cell
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "UserProfileCell", bundle: nil), forCellReuseIdentifier: "UserProfileCell")
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(UserViewController.loadData), for: .valueChanged)
    }
    
    @objc fileprivate func loadData() {
        self.refreshControl?.beginRefreshing()
        Server.getProfile(for: user)
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
}
