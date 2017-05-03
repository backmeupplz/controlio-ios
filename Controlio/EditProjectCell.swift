//
//  EditProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 01/02/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

protocol EditProjectCellDelegate {
    func save(project: Project)
    func editPhotoTouched(sender: UIView)
}

class EditProjectCell: UITableViewCell {

    // MARK: - Variables -
    
    var delegate: EditProjectCellDelegate?
    var project: Project! {
        didSet {
            configure()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!

    @IBOutlet weak var titleTextField: TextField!
    @IBOutlet weak var descriptionTextField: TextField!
    @IBOutlet weak var progressBarSwitch: UISwitch!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    // MARK: - Actions -
    
    @IBAction func addPhotoTouched(_ sender: AnyObject) {
        delegate?.editPhotoTouched(sender: sender as! UIView)
    }
    
    @IBAction func saveTouched(_ sender: AnyObject) {
        delegate?.save(project: project)
    }
    
    @IBAction func progressBarSwitchChanged(_ sender: UISwitch) {
        project.progressEnabled = sender.isOn
    }
    
    // MARK: - Private functions -
    
    fileprivate func setup() {
        setupTitleTextField()
        setupDescriptionTextField()
    }
    
    fileprivate func setupTitleTextField() {
        titleTextField.placeholder = NSLocalizedString("Project title", comment: "textfield placeholder")
        titleTextField.detail = NSLocalizedString("How do you name this project?", comment: "textfield detail")
        
        titleTextField.returnKeyType = .next
        
        titleTextField.dividerActiveColor = Color.controlioGreen
        titleTextField.placeholderActiveColor = Color.controlioGreen
        titleTextField.autocapitalizationType = .sentences
        titleTextField.backgroundColor = Color.clear
        
        titleTextField.delegate = self
    }
    
    fileprivate func setupDescriptionTextField() {
        descriptionTextField.placeholder = NSLocalizedString("Project description", comment: "textfield placeholder")
        descriptionTextField.detail = NSLocalizedString("What is this project about?", comment: "textfield detail")
        
        descriptionTextField.returnKeyType = .done
        
        descriptionTextField.dividerActiveColor = Color.controlioGreen
        descriptionTextField.placeholderActiveColor = Color.controlioGreen
        descriptionTextField.autocapitalizationType = .sentences
        descriptionTextField.backgroundColor = Color.clear
        
        descriptionTextField.delegate = self
    }
    
    fileprivate func configure() {
        if let image = project.tempImage {
            cameraImage.isHidden = true
            photoLabel.text = NSLocalizedString("Edit", comment: "button")
            photoImage.image = image
        } else if let key = project.imageKey {
            cameraImage.isHidden = true
            photoLabel.text = NSLocalizedString("Edit", comment: "button")
            photoImage.load(key: key)
        } else {
            cameraImage.isHidden = false
            photoLabel.text = NSLocalizedString("Add", comment: "button")
            photoImage.image = UIImage(named: "photo-background-placeholder")
        }
        
        titleTextField.text = project.title
        descriptionTextField.text = project.projectDescription
        progressBarSwitch.isOn = project.progressEnabled
    }
}

extension EditProjectCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var textFields: [TextField] = [titleTextField, descriptionTextField]
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
        let text = (textField.text ?? "") as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        
        if textField == titleTextField {
            project.title = resultString
        } else if textField == descriptionTextField {
            project.projectDescription = resultString
        }
        
        return true
    }
}
