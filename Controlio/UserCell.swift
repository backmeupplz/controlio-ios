//
//  UserCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 21/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    // MARK: - Variables -
    
    var user: User! {
        didSet {
            configure()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var avatar: CustomizableImageView!
    @IBOutlet weak var name: UILabel!
    
    // MARK: - General functions -
    
    func configure() {
        avatar.loadURL(user.profileImage)
        name.text = user.name ?? user.email
    }
}
