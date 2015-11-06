//
//  ProjectDescriptionCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 18/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class ProjectDescriptionCell: UITableViewCell {
    
    // MARK: - Public Variables -
    
    var object: ProjectObject! {
        didSet {
            setup()
        }
    }
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var companyLogo: RoundImageView!
    @IBOutlet weak var companyTitle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var managerImageView: UIImageView!
    @IBOutlet weak var managerName: UILabel!
    @IBOutlet weak var managerPhoneButton: UIButton!
    @IBOutlet weak var managerEmailButton: UIButton!
    @IBOutlet weak var managerWebsiteButton: UIButton!
    
    // MARK: - General Methods -
    
    func setup() {
        companyLogo.loadURL(object.image)
        companyTitle.text = arc4random() % 2 == 0 ? "Starbucks Canada" : "Santa Ventures"
        titleLabel.text = object.title
        infoLabel.text = object.info
        
        managerImageView.loadURL(object.manager.image)
        managerName.text = object.manager.name
        managerPhoneButton.setTitle(object.manager.telephone, forState:.Normal)
        managerEmailButton.setTitle(object.manager.email, forState:.Normal)
        managerWebsiteButton.setTitle(object.manager.website, forState:.Normal)
    }
}