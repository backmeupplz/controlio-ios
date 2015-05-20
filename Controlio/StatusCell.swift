//
//  StatusCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class StatusCell: UITableViewCell {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var managerImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Public Variables -
    
    var manager: ManagerObject!
    var object: StatusObject! {
        didSet {
            configure()
        }
    }
    
    // MARK: - General Methods -
    
    func configure() {
        if (object.type == StatusType.Status) {
            managerImageView.loadURL(manager.image)
        }
        statusLabel.text = object.text
    }
}