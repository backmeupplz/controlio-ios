//
//  ProjectInfoController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SnapKit

class ProjectInfoController: UITableViewController {
    
    // MARK: - Variables -
    
    var project: Project!
    var sections = ["Info", "Owner", "Managers", "Clients", "Managers invited", "Clients invited", "Owner invited"]
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupTableView()
    }
    
    // MARK: - UITableViewDataSource -
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // MARK: - UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        
        switch indexPath.section {
            case 0:
                let projectCell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectCell
                projectCell.type = .info
                projectCell.project = project
                cell = projectCell
            case 1, 2, 3, 4, 5, 6:
                let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                switch indexPath.section {
                case 1:
                    userCell.user = project.owner!
                case 2:
                    userCell.user = project.managers[indexPath.row]
                case 3:
                    userCell.user = project.clients[indexPath.row]
                case 4:
                    userCell.user = project.managersInvited[indexPath.row].invitee
                case 5:
                    userCell.user = project.clientsInvited[indexPath.row].invitee
                case 6:
                    userCell.user = project.ownerInvited!.invitee
                default:
                    break
                }
                cell = userCell
            default:
                return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = UIView()
        let label = UILabel()
        header.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(header)
            make.left.equalTo(header).offset(15)
            make.bottom.equalTo(header)
            make.right.equalTo(header).offset(-15)
        }
        label.textColor = UIColor(red: 88.0/255.0, green: 93.0/255.0, blue: 108.0/255.0, alpha: 1.0)
        label.text = sections[section]
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1
        case 1:
            return project.owner == nil ? 0 : 44
        case 2:
            return project.managers.count == 0 ? 0 : 44
        case 3:
            return project.clients.count == 0 ? 0 : 44
        case 4:
            return project.managersInvited.count == 0 ? 0 : 44
        case 5:
            return project.clientsInvited.count == 0 ? 0 : 44
        case 6:
            return project.ownerInvited == nil ? 0 : 44
        default:
            return 0
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func configure() {
        title = project.title
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 464.0
        tableView.register(UINib(nibName: "ProjectCell", bundle: nil), forCellReuseIdentifier: "ProjectCell")
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
}
