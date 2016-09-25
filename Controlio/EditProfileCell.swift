//
//  EditProfileCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

protocol EditProfileCellDelegate: class {
    func editPhotoTouched()
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
        delegate?.editPhotoTouched()
    }
    
    // MARK: - Private functions -
    
    func configure() {
        guard let user = user else { return }
        
        if let url = user.profileImage {
            addPhotoBackground.loadURL(url)
            addPhotoCamera.isHidden = true
            addPhotoLabel.text = "Edit photo"
        } else if let image = user.tempProfileImage {
            addPhotoBackground.image = image
            addPhotoCamera.isHidden = true
            addPhotoLabel.text = "Edit photo"
        } else {
            addPhotoBackground.image = UIImage(named: "photo-background-placeholder")
            addPhotoCamera.isHidden = false
            addPhotoLabel.text = "Add photo"
        }
        
        nameTextfield.text = user.name
        emailTextfield.text = user.email
        phoneTextfield.text = user.phone
    }
}
