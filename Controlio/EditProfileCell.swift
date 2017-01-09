//
//  EditProfileCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

protocol EditProfileCellDelegate: class {
    func editPhotoTouched(sender: UIView)
    func saveTouched()
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
    
    @IBOutlet weak var nameTextfield: TextField!
    @IBOutlet weak var emailTextfield: TextField!
    @IBOutlet weak var phoneTextfield: TextField!
    
    // MARK: - Actions -
    
    @IBAction func editPhotoTouched(_ sender: AnyObject) {
        delegate?.editPhotoTouched(sender: sender as! UIView)
    }
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: - Private functions -
    
    fileprivate func setup() {
        setupNameTextField()
        setupEmailTextField()
        setupPhoneTextField()
    }
    
    fileprivate func setupNameTextField() {
        nameTextfield.placeholder = "Name"
        nameTextfield.returnKeyType = .continue
        nameTextfield.keyboardType = .default
        nameTextfield.delegate = self
        nameTextfield.tintColor = Color.controlioGreen()
        nameTextfield.dividerActiveColor = Color.controlioGreen()
        nameTextfield.placeholderActiveColor = Color.controlioGreen()
        nameTextfield.autocapitalizationType = .words
    }
    
    fileprivate func setupEmailTextField() {
        emailTextfield.placeholder = "Email"
        emailTextfield.detail = "You cannot change the email yet"
        emailTextfield.returnKeyType = .continue
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.isEnabled = false
        emailTextfield.delegate = self
        emailTextfield.tintColor = Color.controlioGreen()
        emailTextfield.dividerActiveColor = Color.controlioGreen()
        emailTextfield.placeholderActiveColor = Color.controlioGreen()
    }
    
    fileprivate func setupPhoneTextField() {
        phoneTextfield.placeholder = "Phone"
        phoneTextfield.detail = "Visible to your clients and project managers"
        phoneTextfield.returnKeyType = .done
        phoneTextfield.keyboardType = .phonePad
        phoneTextfield.delegate = self
        phoneTextfield.tintColor = Color.controlioGreen()
        phoneTextfield.dividerActiveColor = Color.controlioGreen()
        phoneTextfield.placeholderActiveColor = Color.controlioGreen()
    }
    
    fileprivate func configure() {
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

extension EditProfileCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields: [TextField] = [emailTextfield, phoneTextfield]
        if let last = textFields.last,
            let textField = textField as? TextField {
            if textField == last {
                textField.resignFirstResponder()
                delegate?.saveTouched()
            } else {
                let index = textFields.index(of: textField) ?? 0
                textFields[index + 1].becomeFirstResponder()
            }
        }
        return false
    }
}
