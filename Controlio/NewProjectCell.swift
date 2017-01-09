//
//  NewProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

protocol NewProjectCellDelegate: class {
    func editPhotoTouched(sender: UIView)
    func choosePeopleTouched()
    func createTouched()
}

class NewProjectCell: UITableViewCell {
    
    // MARK: - Variables -
    
    var delegate: NewProjectCellDelegate?
    
    // MARK: - Outlets -
    
    @IBOutlet weak var photoImage: CustomizableImageView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    
    @IBOutlet weak var typePicker: UISegmentedControl!
    @IBOutlet weak var titleTextField: TextField!
    @IBOutlet weak var descriptionTextField: TextField!
    @IBOutlet weak var initialStatusTextField: TextField!
    @IBOutlet weak var peopleTextField: TextField!
    @IBOutlet weak var peopleButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    // MARK: - Actions -
    
    @IBAction func addPhotoTouched(_ sender: AnyObject) {
        delegate?.editPhotoTouched(sender: sender as! UIView)
    }
    
    @IBAction func typePicked(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func choosePeopleTouched(_ sender: AnyObject) {
        delegate?.choosePeopleTouched()
    }
    
    @IBAction func createTouched(_ sender: AnyObject) {
        delegate?.createTouched()
    }
    
    // MARK: - Private functions -
    
    fileprivate func setup() {
        setupTitleTextField()
        setupDescriptionTextField()
        setupInitialStatusTextField()
        setupPeopleTextField()
    }
    
    fileprivate func setupTitleTextField() {
        titleTextField.placeholder = "* Project title"
        titleTextField.detail = "How will you name your project?"
        
        titleTextField.returnKeyType = .next
        
        titleTextField.dividerActiveColor = Color.controlioGreen()
        titleTextField.placeholderActiveColor = Color.controlioGreen()
        titleTextField.autocapitalizationType = .sentences
        titleTextField.backgroundColor = Color.clear
        
        titleTextField.delegate = self
    }
    
    fileprivate func setupDescriptionTextField() {
        descriptionTextField.placeholder = "Project description"
        descriptionTextField.detail = "What is your project about?"
        
        descriptionTextField.returnKeyType = .next
        
        descriptionTextField.dividerActiveColor = Color.controlioGreen()
        descriptionTextField.placeholderActiveColor = Color.controlioGreen()
        descriptionTextField.autocapitalizationType = .sentences
        descriptionTextField.backgroundColor = Color.clear
        
        descriptionTextField.delegate = self
    }
    
    fileprivate func setupInitialStatusTextField() {
        initialStatusTextField.placeholder = "Initial status"
        initialStatusTextField.detail = "What is the current status of the project"
        
        initialStatusTextField.returnKeyType = .next
        
        initialStatusTextField.dividerActiveColor = Color.controlioGreen()
        initialStatusTextField.placeholderActiveColor = Color.controlioGreen()
        initialStatusTextField.autocapitalizationType = .sentences
        initialStatusTextField.backgroundColor = Color.clear
        
        initialStatusTextField.delegate = self
    }
    
    fileprivate func setupPeopleTextField() {
        peopleTextField.placeholder = "* Manager's email"
        peopleTextField.detail = "Email of the manager who will send you updates"
        
        peopleTextField.returnKeyType = .continue
        
        peopleTextField.dividerActiveColor = Color.controlioGreen()
        peopleTextField.placeholderActiveColor = Color.controlioGreen()
        peopleTextField.backgroundColor = Color.clear
        
        peopleTextField.delegate = self
    }
}

extension NewProjectCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields: [TextField] = [titleTextField, descriptionTextField, initialStatusTextField]
        if let last = textFields.last,
            let textField = textField as? TextField {
            if textField == last {
                textField.resignFirstResponder()
                print("Should show select manager or clients")
            } else {
                let index = textFields.index(of: textField) ?? 0
                textFields[index + 1].becomeFirstResponder()
            }
        }
        return false
    }
}
