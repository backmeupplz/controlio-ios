//
//  ProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ProjectCell: UITableViewCell {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var companyLogo: RoundImageView!
    @IBOutlet weak var companyTitle: UILabel!
    @IBOutlet weak var titleMessageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Public Variables -
    
    var object: ProjectObject! {
        didSet {
            configure()
        }
    }
    
    // MARK: - General Methods -
    
    func configure() {
        companyLogo.loadURL(object.image)
        companyTitle.text = arc4random() % 2 == 0 ? "Starbucks Canada" : "Santa Ventures"
        titleMessageLabel.text = object.title
        timestampLabel.text = object.shortTimestampString
        messageLabel.text = object.message
        statusLabel.text = object.status
    }
}