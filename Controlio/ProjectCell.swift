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
    @IBOutlet weak var projectDescriptionLabel: UILabel!
    
    @IBOutlet weak var projectImageViewLeft: NSLayoutConstraint!
    @IBOutlet weak var projectImageViewWidth: NSLayoutConstraint!
    
    // MARK: - Private Functions -
    
    fileprivate func configure() {
        if let key = project.imageKey {
            projectImageView.image = UIImage(named: "photo-background-placeholder")
            projectImageViewLeft.constant = 15
            projectImageViewWidth.constant = 60
            projectImageView.load(key: key)
        } else {
            projectImageView.image = UIImage(named: "photo-background-placeholder")
            projectImageViewLeft.constant = 0
            projectImageViewWidth.constant = 0
        }
        if let date = project.dateUpdated {
            dateLabel.text = DateFormatter.projectDateString(date)
        } else {
            dateLabel.text = ""
        }
        projectTitleLabel.text = project.title
        if let text = project.lastPost?.text {
            projectDescriptionLabel.alpha = 1
            projectDescriptionLabel.text = text
        } else {
            projectDescriptionLabel.alpha = 0.5
            projectDescriptionLabel.text = "Nothing here yet"
        }
        
    }
    
}
