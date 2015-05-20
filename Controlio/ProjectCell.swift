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
    
    @IBOutlet weak var lastImageView: UIImageView!
    @IBOutlet weak var titleMessageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Public Variables -
    
    var object: ProjectObject! {
        didSet {
            configure()
        }
    }
    
    // MARK: - General Methods -
    
    func configure() {
        lastImageView.loadURL(object.image)
        titleMessageLabel.text = object.title
        timestampLabel.text = object.timestampString
        statusLabel.text = object.message
    }
}