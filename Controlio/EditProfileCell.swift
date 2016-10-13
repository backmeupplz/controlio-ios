//
//  EditProfileCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

protocol EditProfileCellDelegate: class {
    func editPhotoTouched(sender: UIView)
}

class EditProfileCell: UITableViewCell {
    
    // MARK: - Variables -
    
    weak var delegate: EditProfileCellDelegate?
    var user: User? {
        didSet {
            configure()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var addPhotoBackground: CustomizableImageView!
    @IBOutlet weak var addPhotoCamera: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    
    // MARK: - Actions -
    
    @IBAction func editPhotoTouched(_ sender: AnyObject) {
        delegate?.editPhotoTouched(sender: sender as! UIView)
    }
    
    // MARK: - Private functions -
    
    func configure() {
        guard let user = user else { return }
        
        if let image = user.tempProfileImage {
            addPhotoBackground.image = image
            addPhotoCamera.isHidden = true
            addPhotoLabel.text = NSLocalizedString("Edit photo", comment: "Edit profile image label")
        } else if let key = user.profileImageKey {
            addPhotoBackground.load(key: key)
            addPhotoCamera.isHidden = true
            addPhotoLabel.text = NSLocalizedString("Edit photo", comment: "Edit profile image label")
        } else {
            addPhotoBackground.image = UIImage(named: "photo-background-placeholder")
            addPhotoCamera.isHidden = false
            addPhotoLabel.text = NSLocalizedString("Add photo", comment: "Edit profile image label")
        }
        
        nameTextfield.text = user.name
        emailTextfield.text = user.email
        phoneTextfield.text = user.phone
    }
}
