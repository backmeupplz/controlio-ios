//
//  NewProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import CLTokenInputView

protocol NewProjectCellDelegate: class {
    func editPhotoTouched(sender: UIView)
    func chooseManagerTouched()
    func createTouched()
}

class NewProjectCell: UITableViewCell, UITextFieldDelegate, CLTokenInputViewDelegate {
    
    // MARK: - Variables -
    
    var delegate: NewProjectCellDelegate?
    
    // MARK: - Outlets -
    
    @IBOutlet weak var photoImage: CustomizableImageView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var initialStatusTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var clientEmailsTokenView: CLTokenInputView!
    
    @IBOutlet weak var managerPhotoImage: UIImageView!
    @IBOutlet weak var managerTitleLabel: UILabel!
    @IBOutlet weak var chooseManagerButton: UIButton!
    @IBOutlet weak var chooseManagerBackgroundButton: UIButton!
    
    @IBOutlet weak var detailDisclosureImage: UIImageView!
    
    @IBOutlet weak var createButton: RoundedShadowedButton!
    
    // MARK: - UITextFieldDelegate -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - CLTokenInputViewDelegate -
    
    func tokenInputView(_ view: CLTokenInputView, didChangeText text: String?) {
        
    }
    
    func tokenInputView(_ view: CLTokenInputView, didAdd token: CLToken) {
        setNeedsLayout()
    }
    
    func tokenInputView(_ view: CLTokenInputView, didRemove token: CLToken) {
        setNeedsLayout()
    }
    
    func tokenInputViewDidEndEditing(_ view: CLTokenInputView) {
        view.accessoryView = nil
    }
    
    func tokenInputViewDidBeginEditing(_ view: CLTokenInputView) {
        view.accessoryView = contactAddButton()
    }
    
    func tokenInputViewShouldReturn(_ view: CLTokenInputView) -> Bool {
        addTokenTouched()
        return false
    }
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTokenInputView()
    }
    
    // MARK: - Actions -
    
    @IBAction func addPhotoTouched(_ sender: AnyObject) {
        delegate?.editPhotoTouched(sender: sender as! UIView)
    }
    
    @IBAction func chooseManagerTouched(_ sender: AnyObject) {
        delegate?.chooseManagerTouched()
    }
    
    @IBAction func createTouched(_ sender: AnyObject) {
        delegate?.createTouched()
    }
    
    func addTokenTouched() {
        let text = clientEmailsTokenView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        if !text.isEmpty && text.isEmail {
            let token = CLToken(displayText: text, context: nil)
            clientEmailsTokenView.add(token)
        } else {
            PopupNotification.showNotification(NSLocalizedString("Please provide a valid email", comment: "Error"))
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupTokenInputView() {
        clientEmailsTokenView.tintColor = UIColor.controlioGreen()
        clientEmailsTokenView.placeholderText = NSLocalizedString("Client emails", comment: "Token input view placeholder")
        clientEmailsTokenView.textField.font = UIFont(name: "SFUIText-Regular", size: 14)
    }
    
    fileprivate func contactAddButton() -> UIButton {
        let contactAddButton = UIButton(type: .contactAdd)
        contactAddButton.addTarget(self, action: #selector(NewProjectCell.addTokenTouched), for: .touchUpInside)
        return contactAddButton
    }
}
