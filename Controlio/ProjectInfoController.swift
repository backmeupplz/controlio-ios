//
//  ProjectInfoController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD
import Material
import AsyncDisplayKit

class ProjectInfoController: ASViewController<ASDisplayNode> {
    
    // MARK: - Variables -
    
    fileprivate var tableNode: ASTableNode!
    fileprivate var project: Project!
    fileprivate var sections = ["Info", "Owner", "Managers", "Clients", "Managers invited", "Clients invited", "Owner invited"]
    fileprivate var refreshControl: UIRefreshControl?
    
    // MARK: - View Controller Life Cycle -
    
    init(with project: Project) {
        let tableNode = ASTableNode(style: .plain)
        
        super.init(node: tableNode)
        
        self.tableNode = tableNode
        self.tableNode.dataSource = self
        self.tableNode.delegate = self
        self.project = project
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupTableView()
        setupBackButton()
        addRefreshControl()
        addRightButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reload()
    }
    
    // MARK: - Private functions -
    
    fileprivate func configure() {
        title = project.title
    }
    
    fileprivate func setupTableView() {
        tableNode.view.tableFooterView = UIView()
        tableNode.view.backgroundColor = Color.controlioTableBackground
        tableNode.view.contentInset = EdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        tableNode.view.separatorStyle = .none
    }
    
    fileprivate func setupBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func addRefreshControl() {
        refreshControl = UIRefreshControl()
        guard let refreshControl = refreshControl else { return }
        tableNode.view.addSubview(refreshControl)
        tableNode.view.sendSubview(toBack: refreshControl)
        refreshControl.addTarget(self, action: #selector(ProjectInfoController.reload), for: .valueChanged)
    }
    
    fileprivate func addRightButton() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(Icon.moreHorizontal, for: .normal)
        button.addTarget(self, action: #selector(ProjectInfoController.moreTouched(sender:)), for: .touchUpInside)
        let rightView = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = rightView
    }
    
    @objc fileprivate func reload() {
        Server.get(project: project)
        { error, project in
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                self.project = project
                self.configure()
                self.tableNode.reloadSections(IndexSet(0...6), with: .fade)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func removeManager(from indexPath: IndexPath) {
        guard let user = object(for: indexPath) as? User
            else { return }
        let alert = UIAlertController(title: "Would you like to remove \(user.name ?? user.email ?? "this user") from managers?", preferredStyle: .alert)
        alert.add(action: "Remove", style: .destructive)
        {
            guard let hud = MBProgressHUD.show() else { return }
            hud.label.text = "Removing \(user.name ?? user.email ?? "user") from managers"
            Server.remove(manager: user, from: self.project)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.removeCellAt(indexPath: indexPath)
                    self.snackbarController?.show(text: "\(user.name ?? user.email ?? "This user") has been removed from managers")
                }
            }
        }
        alert.addCancelButton()
        present(alert, animated: true) {}
    }
    
    fileprivate func removeClient(from indexPath: IndexPath) {
        guard let user = object(for: indexPath) as? User
            else { return }
        let alert = UIAlertController(title: "Would you like to remove \(user.name ?? user.email ?? "this user") from clients?", preferredStyle: .alert)
        alert.add(action: "Remove", style: .destructive)
        {
            guard let hud = MBProgressHUD.show() else { return }
            hud.label.text = "Removing \(user.name ?? user.email ?? "user") from clients"
            Server.remove(client: user, from: self.project)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.removeCellAt(indexPath: indexPath)
                    self.snackbarController?.show(text: "\(user.name ?? user.email ?? "This user") has been removed from clients")
                }
            }
        }
        alert.addCancelButton()
        present(alert, animated: true) {}
    }
    
    fileprivate func removeInvite(from indexPath: IndexPath) {
        guard let invite = object(for: indexPath) as? Invite
            else { return }
        let alert = UIAlertController(title: "Would you like to revoke invite to \(invite.invitee?.name ?? invite.invitee?.email ?? "this user")?", preferredStyle: .alert)
        alert.add(action: "Revoke", style: .destructive)
        {
            guard let hud = MBProgressHUD.show() else { return }
            hud.label.text = "Revoking invite for \(invite.invitee?.name ?? invite.invitee?.email ?? "this user")"
            Server.remove(invite: invite)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.removeCellAt(indexPath: indexPath)
                    self.snackbarController?.show(text: "Invite for \(invite.invitee?.name ?? invite.invitee?.email ?? "this user") has been revoked")
                }
            }
        }
        alert.addCancelButton()
        present(alert, animated: true) {}
    }
    
    fileprivate func removeCellAt(indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            project.managers.remove(at: indexPath.row)
        case 3:
            project.clients.remove(at: indexPath.row)
        case 4:
            let invite = project.managersInvited[indexPath.row]
            project.invites = project.invites.filter { $0 != invite }
        case 5:
            let invite = project.clientsInvited[indexPath.row]
            project.invites = project.invites.filter { $0 != invite }
        default:
            break
        }
        tableNode.deleteRows(at: [indexPath], with: .automatic)
    }
    
    @objc fileprivate func addClientsTouched() {
        Router(self).showClients(with: project, type: .addClients)
    }
    
    @objc fileprivate func addManagersTouched() {
        Router(self).showClients(with: project, type: .addManagers)
    }
    
    @objc fileprivate func moreTouched(sender: UIButton) {
        let alert = UIAlertController(sourceView: sender)
        if !project.isOwner {
            alert.add(action: "Leave project", style: .destructive)
            {
                let alert = UIAlertController(title: "Are you sure you want to leave \(self.project.title ?? "this project")?", message: "You will not be able to get back unless you get invited", sourceView: sender)
                alert.add(action: "Leave", style: .destructive)
                {
                    self.leave(project: self.project)
                }
                alert.addCancelButton()
                self.present(alert, animated: true) {}
            }
        } else if project.isOwner {
            alert.add(action: project.isFinished ? "Revive project": "Finish project", style: .default)
            {
                self.toggleFinished(for: self.project)
            }
            alert.add(action: "Delete project", style: .destructive)
            {
                let alert = UIAlertController(title: "Are you sure you want to delete \(self.project.title ?? "this project")?", message: "This action cannot be undone", sourceView: sender)
                alert.add(action: "Delete", style: .destructive)
                {
                    self.delete(project: self.project)
                }
                alert.addCancelButton()
                self.present(alert, animated: true) {}
            }
        }
        if (project.canEdit && !project.isFinished) {
            alert.add(action: "Edit project")
            {
                Router(self).showEdit(of: self.project)
            }
        }
        alert.addCancelButton()
        present(alert, animated: true) {}
    }
    
    fileprivate func leave(project: Project) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = "Leaving the project..."
        
        Server.leave(project: project)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                let _ = self.navigationController?.popToRootViewController(animated: true)
                self.snackbarController?.show(text: "You have left the project")
            }
        }
    }
    
    
    fileprivate func delete(project: Project) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = "Deleting the project..."
        
        Server.delete(project: project)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                let _ = self.navigationController?.popToRootViewController(animated: true)
                self.snackbarController?.show(text: "Project has been deleted")
                self.post(notification: .projectDeleted)
            }
        }
    }
    
    fileprivate func toggleFinished(for project: Project) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = project.isFinished ? "Reviving the project...": "Finishing the project..."
        
        Server.toggleFinished(for: project)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                let _ = self.navigationController?.popToRootViewController(animated: true)
                self.snackbarController?.show(text: project.isFinished ? "Project has been revived": "Project has been finished")
                self.post(notification: .projectArchivedChanged)
            }
        }
    }
    
    fileprivate func object(for indexPath: IndexPath) -> Any? {
        var result: Any?
        switch indexPath.section {
        case 1:
            result = self.project.owner
        case 2:
            result = self.project.managers[indexPath.row]
        case 3:
            result = self.project.clients[indexPath.row]
        case 4:
            result = self.project.managersInvited[indexPath.row]
        case 5:
            result = self.project.clientsInvited[indexPath.row]
        case 6:
            result = self.project.ownerInvited
        default:
            break
        }
        return result
    }
}

extension ProjectInfoController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return sections.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return project.owner == nil ? 0 : 1
        case 2:
            return project.managers.count
        case 3:
            return project.clients.count
        case 4:
            return project.managersInvited.count
        case 5:
            return project.clientsInvited.count
        case 6:
            return project.ownerInvited == nil ? 0 : 1
        default:
            return 0
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            if indexPath.section == 0 {
                return ProjectCell(with: self.project,
                                   type: .info)
            } else {
                switch indexPath.section {
                case 1:
                    return UserCell(with: self.project.owner)
                case 2:
                    return UserCell(with: self.project.managers[indexPath.row])
                case 3:
                    return UserCell(with: self.project.clients[indexPath.row])
                case 4:
                    return UserCell(invite: self.project.managersInvited[indexPath.row])
                case 5:
                    return UserCell(invite: self.project.clientsInvited[indexPath.row])
                case 6:
                    return UserCell(invite: self.project.ownerInvited)
                default:
                    return UserCell()
                }
            }
        }
    }
}
extension ProjectInfoController: ASTableDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = UIView()
        header.backgroundColor = UIColor(red: 244.0/255.0, green: 246.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        let label = UILabel()
        header.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(header)
            make.left.equalTo(header).offset(15)
            make.bottom.equalTo(header)
            if (section != 5 && project.canEdit) && (section != 4 && project.isOwner) {
                make.right.equalTo(header).offset(-15)
            }
        }
        label.textColor = UIColor(red: 88.0/255.0, green: 93.0/255.0, blue: 108.0/255.0, alpha: 1.0)
        label.text = sections[section]
        if section == 5 && project.canEdit {
            // add button to edit clients
            let button = UIButton(type: .system)
            button.setTitle("Invite more clients", for: .normal)
            button.setTitleColor(UIColor.controlioGreen, for: .normal)
            button.addTarget(self, action: #selector(ProjectInfoController.addClientsTouched), for: .touchUpInside)
            header.addSubview(button)
            button.snp.makeConstraints { make in
                make.top.equalTo(header)
                make.bottom.equalTo(header)
                make.left.equalTo(label.snp.right).offset(8)
            }
        }
        if section == 4 && project.isOwner {
            // add button to edit clients
            let button = UIButton(type: .system)
            button.setTitle("Invite more managers", for: .normal)
            button.setTitleColor(UIColor.controlioGreen, for: .normal)
            button.addTarget(self, action: #selector(ProjectInfoController.addManagersTouched), for: .touchUpInside)
            header.addSubview(button)
            button.snp.makeConstraints { make in
                make.top.equalTo(header)
                make.bottom.equalTo(header)
                make.left.equalTo(label.snp.right).offset(8)
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return project.owner == nil ? 0 : 44
        case 2:
            return project.managers.count == 0 ? 0 : 44
        case 3:
            return project.clients.count == 0 ? 0 : 44
        case 4:
            return project.managersInvited.count == 0 && !project.isOwner ? 0 : 44
        case 5:
            return project.clientsInvited.count == 0 && !project.canEdit ? 0 : 44
        case 6:
            return project.ownerInvited == nil ? 0 : 44
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section <= 1 { // info and owner
            return .none
        } else if indexPath.section <= 2 && !project.isOwner { // managers
            return .none
        } else if !project.canEdit {
            return .none
        }
        
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            removeManager(from: indexPath)
        case 3:
            removeClient(from: indexPath)
        case 4, 5, 6:
            removeInvite(from: indexPath)
        default:
            break
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            var optionalUser: User?
            switch indexPath.section {
            case 1:
                optionalUser = self.project.owner
            case 2:
                optionalUser = self.project.managers[indexPath.row]
            case 3:
                optionalUser = self.project.clients[indexPath.row]
            case 4:
                optionalUser = self.project.managersInvited[indexPath.row].invitee
            case 5:
                optionalUser = self.project.clientsInvited[indexPath.row].invitee
            case 6:
                optionalUser = self.project.ownerInvited?.invitee
            default:
                break
            }
            guard let user = optionalUser else { return }
            guard let hud = MBProgressHUD.show() else { return }
            hud.label.text = "Getting user profile..."
            
            Server.getProfile(for: user)
            { error, user in
                hud.hide(animated: true)
                if let error = error {
//                    self.snackbarController?.show(error: error.domain)
                } else if let user = user {
                    Router(self).show(user: user)
                }
            }
        }
    }
}
