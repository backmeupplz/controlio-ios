//
//  ClientsTableViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

class ClientsTableViewController: UITableViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var addButton: UIButton!
    var project: Project!
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Actions -
    
    @IBAction func addTouched(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        
        let isValidEmail = email.isEmail
        let isNotCurrentUser = email != Server.currentUser?.email
        let isDuplicate = project.tempClientEmails.contains(email)
        if isValidEmail && !isDuplicate && isNotCurrentUser {
            emailTextField.text = ""
            tableView.beginUpdates()
            project.tempClientEmails.insert(email, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            tableView.endUpdates()
        } else {
            emailTextField.shake()
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func setup() {
        tableView.tableFooterView = UIView()
        setupEmailTextField()
        setupAddButton()
        emailTextField.becomeFirstResponder()
    }
    
    fileprivate func setupEmailTextField() {
        emailTextField.placeholder = "Email"
        emailTextField.detail = "Email of the client to add"
        
        emailTextField.returnKeyType = .done
        
        emailTextField.placeholderActiveColor = Color.controlioGreen()
        emailTextField.dividerActiveColor = Color.controlioGreen()
        emailTextField.backgroundColor = Color.clear
        
        emailTextField.keyboardType = .emailAddress
        
        emailTextField.delegate = self
    }
    
    fileprivate func setupAddButton() {
        addButton.setImage(Icon.add, for: .normal)
        addButton.tintColor = Color.controlioGreen()
    }
}

extension ClientsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project.tempClientEmails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = project.tempClientEmails[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        project.tempClientEmails.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}

extension ClientsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addTouched(addButton)
        return false
    }
}
