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
    fileprivate var sections = [
        NSLocalizedString("Info", comment: "project info section name"),
        NSLocalizedString("Owner", comment: "project info section name"),
        NSLocalizedString("Managers", comment: "project info section name"),
        NSLocalizedString("Clients", comment: "project info section name"),
        NSLocalizedString("Managers invited", comment: "project info section name"),
        NSLocalizedString("Clients invited", comment: "project info section name"),
        NSLocalizedString("Owner invited", comment: "project info section name")
    ]
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
        let alert = UIAlertController(title: NSLocalizedString("Would you like to remove \(user.name ?? user.email ?? "this user") from managers?", comment: "remove from maangers alert title"), preferredStyle: .alert)
        alert.add(action: NSLocalizedString("Remove", comment: "remove from managers alert button"), style: .destructive)
        {
            guard let hud = MBProgressHUD.show() else { return }
            hud.label.text = NSLocalizedString("Removing \(user.name ?? user.email ?? "user") from managers", comment: "remove from managers hud title")
            Server.remove(manager: user, from: self.project)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.removeCellAt(indexPath: indexPath)
                    self.snackbarController?.show(text: NSLocalizedString("\(user.name ?? user.email ?? "This user") has been removed from managers", comment: "remove from managers success message"))
                }
            }
        }
        alert.addCancelButton()
        present(alert, animated: true) {}
    }
    
    fileprivate func removeClient(from indexPath: IndexPath) {
        guard let user = object(for: indexPath) as? User
            else { return }
        let alert = UIAlertController(title: NSLocalizedString("Would you like to remove \(user.name ?? user.email ?? "this user") from clients?", comment: "remove from clients alert title"), preferredStyle: .alert)
        alert.add(action: NSLocalizedString("Remove", comment: "remove from clients alert button"), style: .destructive)
        {
            guard let hud = MBProgressHUD.show() else { return }
            hud.label.text = NSLocalizedString("Removing \(user.name ?? user.email ?? "user") from clients", comment: "remove from clients hud title")
            Server.remove(client: user, from: self.project)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.removeCellAt(indexPath: indexPath)
                    self.snackbarController?.show(text: NSLocalizedString("\(user.name ?? user.email ?? "This user") has been removed from clients", comment: "remove from clients success message"))
                }
            }
        }
        alert.addCancelButton()
        present(alert, animated: true) {}
    }
    
    fileprivate func removeInvite(from indexPath: IndexPath) {
        guard let invite = object(for: indexPath) as? Invite
            else { return }
        let alert = UIAlertController(title: NSLocalizedString("Would you like to revoke invite to \(invite.invitee?.name ?? invite.invitee?.email ?? "this user")?", comment: "revoke invite alert title"), preferredStyle: .alert)
        alert.add(action: NSLocalizedString("Revoke", comment: "revoke invite alert button"), style: .destructive)
        {
            guard let hud = MBProgressHUD.show() else { return }
            hud.label.text = NSLocalizedString("Revoking invite for \(invite.invitee?.name ?? invite.invitee?.email ?? "this user")", comment: "revoke invite hud title")
            Server.remove(invite: invite)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else {
                    self.removeCellAt(indexPath: indexPath)
                    self.snackbarController?.show(text: NSLocalizedString("Invite for \(invite.invitee?.name ?? invite.invitee?.email ?? "this user") has been revoked", comment: "revoke invite success message"))
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
                let alert = UIAlertController(title: NSLocalizedString("Are you sure you want to leave \(self.project.title ?? "this project")?", comment: "leave project alert title"), message: NSLocalizedString("You will not be able to get back unless you get invited", comment: "leave project alert message"), sourceView: sender)
                alert.add(action: NSLocalizedString("Leave", comment: "leave project alert button"), style: .destructive)
                {
                    self.leave(project: self.project)
                }
                alert.addCancelButton()
                self.present(alert, animated: true) {}
            }
        } else if project.isOwner {
            alert.add(action: project.isFinished ? NSLocalizedString("Revive project", comment: "revive project alert button"): NSLocalizedString("Finish project", comment: "finish project alert button"), style: .default)
            {
                self.toggleFinished(for: self.project)
            }
            alert.add(action: NSLocalizedString("Delete project", comment: "delete project alert button"), style: .destructive)
            {
                let alert = UIAlertController(title: NSLocalizedString("Are you sure you want to delete \(self.project.title ?? "this project")?", comment: "delete project alert title"), message: NSLocalizedString("This action cannot be undone", comment: "delete project alert message"), sourceView: sender)
                alert.add(action: NSLocalizedString("Delete", comment: "delete project alert button"), style: .destructive)
                {
                    self.delete(project: self.project)
                }
                alert.addCancelButton()
                self.present(alert, animated: true) {}
            }
        }
        if (project.canEdit && !project.isFinished) {
            alert.add(action: NSLocalizedString("Edit project", comment: "edit project alert button"))
            {
                Router(self).showEdit(of: self.project)
            }
        }
        alert.addCancelButton()
        present(alert, animated: true) {}
    }
    
    fileprivate func leave(project: Project) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = NSLocalizedString("Leaving the project...", comment: "leave project hud message")
        
        Server.leave(project: project)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                let _ = self.navigationController?.popToRootViewController(animated: true)
                self.snackbarController?.show(text: NSLocalizedString("You have left the project", comment: "leave project success message"))
            }
        }
    }
    
    
    fileprivate func delete(project: Project) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = NSLocalizedString("Deleting the project...", comment: "delete project hud title")
        
        Server.delete(project: project)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                let _ = self.navigationController?.popToRootViewController(animated: true)
                self.snackbarController?.show(text: NSLocalizedString("Project has been deleted", comment: "delete project success message"))
                self.post(notification: .projectDeleted)
            }
        }
    }
    
    fileprivate func toggleFinished(for project: Project) {
        guard let hud = MBProgressHUD.show() else { return }
        hud.label.text = project.isFinished ? NSLocalizedString("Reviving the project...", comment: "revive project hud title"): NSLocalizedString("Finishing the project...", comment: "finish project hud titile")
        
        Server.toggleFinished(for: project)
        { error in
            hud.hide(animated: true)
            if let error = error {
                self.snackbarController?.show(error: error.domain)
            } else {
                let _ = self.navigationController?.popToRootViewController(animated: true)
                self.snackbarController?.show(text: project.isFinished ? NSLocalizedString("Project has been revived", comment: "revive project success message"): NSLocalizedString("Project has been finished", comment: "finish project success message"))
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
            button.setTitle(NSLocalizedString("Invite more clients", comment: "invite more clients header button title"), for: .normal)
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
            button.setTitle(NSLocalizedString("Invite more managers", comment: "invite more managers header button title"), for: .normal)
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
            hud.label.text = NSLocalizedString("Getting user profile...", comment: "get user profile hud title")
            
            Server.getProfile(for: user)
            { error, user in
                hud.hide(animated: true)
                if let error = error {
                    self.snackbarController?.show(error: error.domain)
                } else if let user = user {
                    Router(self).show(user: user)
                }
            }
        }
    }
}
