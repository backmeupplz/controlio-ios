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
        alpha = CGFloat(0)
        lastImageView.sd_setImageWithURL(object.lastImage, completed: { (image, error, type, url) -> Void in
            if (type != .Memory) {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.alpha = CGFloat(1)
                })
            } else {
                self.alpha = CGFloat(1)
            }
        })
        titleMessageLabel.text = object.titleMessage
        timestampLabel.text = object.timestampString
        statusLabel.text = object.lastMessage
    }
}