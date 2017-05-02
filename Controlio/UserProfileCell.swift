//
//  UserProfileCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 31/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit

protocol UserProfileCellDelegate {
    func emailTouched(for user: User)
    func phoneTouched(for user: User)
    func photoTouched(at cell: UserProfileCell)
}

class UserProfileCell: UITableViewCell {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    
    // MARK: - Variables -
    
    var delegate: UserProfileCellDelegate?
    var user: User! {
        didSet {
            configure()
        }
    }
    fileprivate var imageGR: UITapGestureRecognizer?
    
    // MARK: - View life cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageGR = UITapGestureRecognizer(target: self, action: #selector(UserProfileCell.photoTapped))
        photoImageView.addGestureRecognizer(imageGR!)
    }
    
    // MARK: - Actions -
    
    @IBAction func emailTouched(_ sender: Any) {
        delegate?.emailTouched(for: user)
    }
    
    @IBAction func phoneTouched(_ sender: Any) {
        delegate?.phoneTouched(for: user)
    }
    
    func photoTapped() {
        delegate?.photoTouched(at: self)
    }
    
    // MARK: - Private functions -
    
    fileprivate func configure() {
        if let key = user.profileImageKey {
            photoImageView.load(key: key)
        } else {
            photoImageView.image = UIImage(named: "photo-background-placeholder")
        }
        
        if let name = user.name {
            nameLabel.alpha = 1
            nameLabel.text  = name
        } else {
            nameLabel.alpha = 0.5
            nameLabel.text = NSLocalizedString("No name provided", comment: "label placeholder")
        }
        
        emailButton.setTitle(user.email, for: .normal)
        
        if let phone = user.phone {
            phoneButton.isEnabled = true
            phoneButton.setTitle(phone, for: .normal)
        } else {
            phoneButton.isEnabled = false
            phoneButton.setTitle(NSLocalizedString("No phone provided", comment: "label placeholder"), for: .normal)
        }
    }
}
