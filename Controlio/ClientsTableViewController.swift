//
//  ClientsTableViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material
import MBProgressHUD

enum ClientsTableViewControllerType {
    case clients
    case addClients
    case addManagers
}

class ClientsTableViewController: UITableViewController {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var addButton: UIButton!
    var project: Project!
    var type = ClientsTableViewControllerType.clients
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        if type != .clients {
            project.tempClientEmails = []
        }
    }
    
    // MARK: - Actions -
    
    @IBAction func addTouched(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        
        let isValidEmail = email.isEmail
        let isNotCurrentUser = email != Server.currentUser?.email
        let isDuplicate = project.tempClientEmails.contains(email)
        if type == .clients {
            if isValidEmail && !isDuplicate && isNotCurrentUser {
                emailTextField.text = ""
                tableView.beginUpdates()
                project.tempClientEmails.insert(email, at: 0)
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                tableView.endUpdates()
            } else {
                emailTextField.shake()
            }
        } else {
            if !isValidEmail || isDuplicate {
                emailTextField.shake()
                return
            }
            let clientsEmails = project.clients.map { $0.email } + project.clientsInvited.flatMap { $0.invitee?.email }
            let managersEmails = project.managers.map { $0.email } + project.managersInvited.flatMap { $0.invitee?.email }
            let ownerEmail = project.owner?.email
            
            if clientsEmails.contains(where: { $0 == email }) {
                emailTextField.shake()
                snackbarController?.show(error: String(format: NSLocalizedString("%@ is already a client", comment: "snackbar error"), email))
                return
            }
            if managersEmails.contains(where: { $0 == email }) {
                emailTextField.shake()
                snackbarController?.show(error: String(format: NSLocalizedString("%@ is already a manager", comment: "snackbar error"), email))
                return
            }
            if ownerEmail == email {
                emailTextField.shake()
                snackbarController?.show(error: String(format: NSLocalizedString("%@ is already the owner", comment: "snackbar error"), email))
                return
            }
            emailTextField.text = ""
            tableView.beginUpdates()
            project.tempClientEmails.insert(email, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func setup() {
        tableView.tableFooterView = UIView()
        setupEmailTextField()
        setupAddButton()
        let _ = emailTextField.becomeFirstResponder()
        
        if type != .clients {
            addSaveButton()
        }
        
        title = type == .addManagers ? NSLocalizedString("Add managers", comment: "vc title") : NSLocalizedString("Add clients", comment: "vc title")
    }
    
    fileprivate func setupEmailTextField() {
        emailTextField.placeholder = NSLocalizedString("Email", comment: "textfield placeholder")
        emailTextField.detail = type == .addManagers ? NSLocalizedString("Email of the manager to add", comment: "textfield detail") : NSLocalizedString("Email of the client to add", comment: "textfield detail")
        
        emailTextField.returnKeyType = .done
        
        emailTextField.placeholderActiveColor = Color.controlioGreen
        emailTextField.dividerActiveColor = Color.controlioGreen
        emailTextField.backgroundColor = Color.clear
        
        emailTextField.keyboardType = .emailAddress
        
        emailTextField.delegate = self
        emailTextField.autocorrectionType = .no
    }
    
    fileprivate func setupAddButton() {
        addButton.setImage(Icon.add, for: .normal)
        addButton.tintColor = Color.controlioGreen
    }
    
    fileprivate func addSaveButton() {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ClientsTableViewController.saveTouched))
        navigationItem.rightBarButtonItem = button
    }
    
    @objc fileprivate func saveTouched() {
        guard let hud = MBProgressHUD.show() else { return }
        let emails = project.tempClientEmails
        
        if type == .addManagers {
            hud.detailsLabel.text = NSLocalizedString("Adding managers...", comment: "hud title")
            Server.add(managers: emails, to: project)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    let _ = self.navigationController?.popViewController(animated: true)
                    self.snackbarController?.show(text: NSLocalizedString("Managers were successfully added", comment: "snackbar message"))
                }
            }
        } else if type == .addClients {
            hud.detailsLabel.text = NSLocalizedString("Adding clients...", comment: "hud title")
            Server.add(clients: emails, to: project)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    let _ = self.navigationController?.popViewController(animated: true)
                    self.snackbarController?.show(text: NSLocalizedString("Clients were successfully added", comment: "snackbar message"))
                }
            }
        }
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
