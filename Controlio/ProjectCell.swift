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
    
    @IBOutlet weak var roundedView: UIView!
    
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
        projectImageView.load(key: project.imageKey)
        dateLabel.text = DateFormatter.projectDateString(project.dateCreated)
        projectTitleLabel.text = project.title
        statusLabel.text = project.lastStatus?.text
        projectDescriptionLabel.text = project.projectDescription
        
        if let managerImageKey = project.manager.profileImageKey {
            managerImageView.load(key: managerImageKey)
        } else {
            managerImageView.image = UIImage(named: "photo-background-placeholder")
        }
        managerNameLabel.text = project.manager.name ?? project.manager.email
        postLabel.text = project.lastPost?.text ?? project.lastStatus?.text
        
        roundedView.alpha = project.isArchived ? 0.5 : 1.0
    }
    
}
