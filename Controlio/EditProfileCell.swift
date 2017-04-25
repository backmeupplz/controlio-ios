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

enum Codes: Int {
    case area
    case country
}

class EditProfileCell: UITableViewCell {
    
    // MARK: - Variables -
    let localNumberMaxLength = 7
    let areaCodeMaxLength = 3
    let countryCodeMaxLength = 3

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
        nameTextfield.placeholder = NSLocalizedString("Name", comment: "textfield palceholder")
        nameTextfield.returnKeyType = .continue
        nameTextfield.keyboardType = .default
        nameTextfield.delegate = self
        nameTextfield.tintColor = Color.controlioGreen
        nameTextfield.dividerActiveColor = Color.controlioGreen
        nameTextfield.placeholderActiveColor = Color.controlioGreen
        nameTextfield.autocapitalizationType = .words
    }
    
    fileprivate func setupEmailTextField() {
        emailTextfield.placeholder = NSLocalizedString("Email", comment: "textfield placeholder")
        emailTextfield.detail = NSLocalizedString("You cannot change the email yet", comment: "textfield detail")
        emailTextfield.returnKeyType = .continue
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.isEnabled = false
        emailTextfield.delegate = self
        emailTextfield.tintColor = Color.controlioGreen
        emailTextfield.dividerActiveColor = Color.controlioGreen
        emailTextfield.placeholderActiveColor = Color.controlioGreen
        emailTextfield.autocorrectionType = .no
    }
    
    fileprivate func setupPhoneTextField() {
        phoneTextfield.placeholder = NSLocalizedString("Phone", comment: "textfield placeholder")
        phoneTextfield.detail = NSLocalizedString("Visible to your clients and project managers", comment: "textfield detail")
        phoneTextfield.returnKeyType = .done
        phoneTextfield.keyboardType = .phonePad
        phoneTextfield.delegate = self
        phoneTextfield.tintColor = Color.controlioGreen
        phoneTextfield.dividerActiveColor = Color.controlioGreen
        phoneTextfield.placeholderActiveColor = Color.controlioGreen
        phoneTextfield.autocorrectionType = .no
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
    func makeSubRange(of string: String, withStartPoint startPoint: Int, andEndPoint endPoint: Int, forCode code: Codes) -> String {
        
        if let range = string.range(of: string) {
            
            let startRange = string.index(range.lowerBound,
                                          offsetBy: startPoint)
            let lastRange = string.index(range.lowerBound,
                                         offsetBy: startPoint + endPoint)
            
            let subRange = startRange..<lastRange
            
            var form = string.substring(with: subRange)
            
            if code == .area {
                form = "(\(form)) "
            } else {
                form = "+\(form) "
            }
            
            return form
        }
        return ""
    }
}

extension EditProfileCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields: [TextField] = [emailTextfield, phoneTextfield]
        if let last = textFields.last,
            let textField = textField as? TextField {
            if textField == last {
                textField.resignFirstResponder()
            } else {
                let index = textFields.index(of: textField) ?? 0
                let _ = textFields[index + 1].becomeFirstResponder()
            }
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let validationSet = CharacterSet.decimalDigits.inverted
        let components = string.components(separatedBy: validationSet)
        
        if components.count > 1 {
            return false
        }
        var newString = textField.text! + string
        
        let newComponents = newString.components(separatedBy: validationSet)
        newString = newComponents.joined(separator: "")
        
        if string == "" {
            
            newString = newString.substring(to: newString.index(before: newString.endIndex))
        }
        
        var resultString = ""
        
        if newString.characters.count > localNumberMaxLength + areaCodeMaxLength + countryCodeMaxLength  {
            return false
        }
        
        let localNumberLength = min(newString.characters.count, localNumberMaxLength)
        
        if localNumberLength >= 0 {
            
            let number = newString.substring(from:
                newString.index(newString.startIndex,
                                offsetBy: newString.characters.count - localNumberLength))
            
            resultString += number
            
            if resultString.characters.count > 3 {
                resultString.insert("-", at: resultString.index(resultString.startIndex, offsetBy: 3))
            }
            
            if resultString.characters.count > 6 {
                resultString.insert("-", at: resultString.index(resultString.startIndex, offsetBy: 6))
            }
        }
        
        if newString.characters.count > localNumberMaxLength {
            
            let areaCodeLength = min(newString.characters.count - localNumberMaxLength, areaCodeMaxLength)
            
            let area = makeSubRange(of: newString,
                                    withStartPoint: newString.characters.count - localNumberMaxLength - areaCodeLength,
                                    andEndPoint: areaCodeLength,
                                    forCode: .area)
            
            resultString = area + resultString
        }
        
        if newString.characters.count > localNumberMaxLength + areaCodeMaxLength {
            
            let countryCodeLength = min(newString.characters.count - localNumberMaxLength - areaCodeMaxLength,
                                        countryCodeMaxLength)
            
            let country = makeSubRange(of: newString,
                                       withStartPoint: newString.characters.count - localNumberMaxLength -
                                        areaCodeMaxLength - countryCodeLength,
                                       andEndPoint: countryCodeLength,
                                       forCode: .country)
            
            resultString = country + resultString
        }
        
        textField.text = resultString
        
        return false
    }

}
