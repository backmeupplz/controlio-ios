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
    
    var invite: Invite? {
        didSet {
            configure()
        }
    }
    
    var user: User? {
        didSet {
            configure()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var avatar: CustomizableImageView!
    @IBOutlet weak var name: UILabel!
    
    // MARK: - General functions -
    
    func configure() {
        if let invite = invite {
            avatar.load(key: invite.invitee?.profileImageKey)
            name.text = invite.invitee?.name ?? invite.invitee?.email
        } else if let user = user {
            avatar.load(key: user.profileImageKey)
            name.text = user.name ?? user.email
        }
    }
}
