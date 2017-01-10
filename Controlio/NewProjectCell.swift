//
//  NewProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

enum NewProjectCellType: Int {
    case client = 0
    case business = 1
}

protocol NewProjectCellDelegate: class {
    func editPhotoTouched(sender: UIView)
    func choosePeopleTouched()
    func createTouched()
}

class NewProjectCell: UITableViewCell {
    
    // MARK: - Variables -
    
    var type = NewProjectCellType.client
    var delegate: NewProjectCellDelegate?
    var project: Project! {
        didSet {
            configure()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    
    @IBOutlet weak var typePicker: UISegmentedControl!
    @IBOutlet weak var titleTextField: TextField!
    @IBOutlet weak var descriptionTextField: TextField!
    @IBOutlet weak var initialStatusTextField: TextField!
    @IBOutlet weak var managerTextField: TextField!
    @IBOutlet weak var clientsTextField: TextField!
    @IBOutlet weak var clientsButton: UIButton!
    
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
        type = NewProjectCellType(rawValue: sender.selectedSegmentIndex)!
        project.tempType = type
        setup(for: type)
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
        setupManagerTextField()
        setupClientsTextField()
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
    
    fileprivate func setupManagerTextField() {
        managerTextField.placeholder = "* Manager's email"
        managerTextField.detail = "Email of the manager who will send you updates"
        
        managerTextField.returnKeyType = .continue
        managerTextField.keyboardType = .emailAddress
        
        managerTextField.dividerActiveColor = Color.controlioGreen()
        managerTextField.placeholderActiveColor = Color.controlioGreen()
        managerTextField.backgroundColor = Color.clear
        
        managerTextField.delegate = self
    }
    
    fileprivate func setupClientsTextField() {
        clientsTextField.placeholder = "* Clients' emails"
        clientsTextField.detail = "Emails of your clients relevant to this project"
        
        clientsTextField.returnKeyType = .continue
        clientsTextField.keyboardType = .emailAddress
        
        clientsTextField.dividerActiveColor = Color.controlioGreen()
        clientsTextField.placeholderActiveColor = Color.controlioGreen()
        clientsTextField.backgroundColor = Color.clear
        
        clientsTextField.delegate = self
    }
    
    fileprivate func setup(for type: NewProjectCellType) {
        managerTextField.isHidden = type == .business
        clientsTextField.isHidden = type == .client
        clientsButton.isUserInteractionEnabled = type == .business
    }
    
    fileprivate func configure() {
        if let image = project.tempImage {
            cameraImage.isHidden = true
            photoLabel.text = "Edit"
            photoImage.image = image
        } else if let key = project.imageKey {
            cameraImage.isHidden = true
            photoLabel.text = "Edit"
            photoImage.load(key: key)
        } else {
            cameraImage.isHidden = false
            photoLabel.text = "Add"
            photoImage.image = UIImage(named: "photo-background-placeholder")
        }
        
        typePicker.selectedSegmentIndex = project.tempType.rawValue
        setup(for: project.tempType)
        titleTextField.text = project.title
        descriptionTextField.text = project.projectDescription
        initialStatusTextField.text = project.tempInitialStatus
        managerTextField.text = project.tempManagerEmail
        clientsTextField.text = project.tempClientEmails.joined(separator: ", ")
    }
}

extension NewProjectCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var textFields: [TextField] = [titleTextField, descriptionTextField, initialStatusTextField]
        if type == .client {
            textFields.append(managerTextField)
        }
        if let last = textFields.last,
            let textField = textField as? TextField {
            if textField == last {
                textField.resignFirstResponder()
                if type == .client {
                    createTouched(createButton)
                } else {
                    choosePeopleTouched(clientsButton)
                }
            } else {
                let index = textFields.index(of: textField) ?? 0
                textFields[index + 1].becomeFirstResponder()
            }
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        
        if textField == titleTextField {
            project?.title = resultString
        } else if textField == descriptionTextField {
            project?.projectDescription = resultString
        } else if textField == initialStatusTextField {
            project?.tempInitialStatus = resultString
        } else if textField == managerTextField {
            project?.tempManagerEmail = resultString
        }
        
        return true
    }
}
