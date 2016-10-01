//
//  AttachmentContainerView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

protocol AttachmentContainerViewDelegate: class {
    func closeImagePicker()
}

class AttachmentContainerView: UIView, PickerDelegate {
    
    // MARK: - Variables -
    
    weak var delegate: AttachmentContainerViewDelegate?
    
    // MARK: - Outlets -
    
    @IBOutlet weak var wrapperView: AttachmentWrapperView!
    
    // MARK: - View Life Cycle -
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        wrapperView.preferredMaxLayoutWidth = wrapperView.frame.width
        super.layoutSubviews()
    }
    
    // MARK: - UIImagePickerControllerDelegate -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            wrapperView.attachments.append(pickedImage)
        }
        
        delegate?.closeImagePicker()
    }
}
