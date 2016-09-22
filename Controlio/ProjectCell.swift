//
//  ProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 13/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {
    
    // MARK: - Variables -
    
    var project: Project! {
        didSet {
            configure()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet fileprivate weak var projectImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var projectDescriptionLabel: UILabel!
    
    @IBOutlet fileprivate weak var managerImageView: UIImageView!
    @IBOutlet weak var managerNameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    
    // MARK: - Private Functions -
    
    fileprivate func configure() {
        projectImageView.loadURL(project.image)
        dateLabel.text = DateFormatter.projectDateString(project.dateCreated)
        projectTitleLabel.text = project.title
        statusLabel.text = project.status
        projectDescriptionLabel.text = project.projectDescription
        
        managerImageView.loadURL(project.manager.profileImage)
        managerNameLabel.text = project.manager.name
        postLabel.text = project.lastPost?.text ?? project.status
    }
    
}
