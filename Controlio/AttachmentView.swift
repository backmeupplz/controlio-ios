//
//  AttachmentView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import NohanaImagePicker

protocol AttachmentViewDelegate: class {
    func attachmentDidTouchCross(_ attachment: AttachmentView)
    func attachmentWasTouched(_ attachment: AttachmentView)
}

class AttachmentView: UIView {
    
    weak var imagePicker: NohanaImagePickerController?

    // MARK: - Variables -
    
    weak var delegate: AttachmentViewDelegate?
    var image: UIImage? {
        set {
            imageView.image = newValue
        }
        get {
            return imageView.image
        }
    }
    var imageKey: String? {
        didSet {
            imageView.image = nil
            imageView.load(key: imageKey)
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet fileprivate weak var imageView: CustomizableImageView!
    
    // MARK: - Class Functions -
    
    class func view(_ superview: UIView, delegate: AttachmentViewDelegate? = nil) -> AttachmentView {
        let result = Bundle.main.loadNibNamed("AttachmentView", owner: nil, options: [:])?.last as! AttachmentView
        result.delegate = delegate
        superview.addSubview(result)
        return result
    }
    
    // MARK: - Actions -

    @IBAction func crossTouched(_ sender: AnyObject) {
        delegate?.attachmentDidTouchCross(self)
    }

    @IBAction func attachmentTouched(_ sender: AnyObject) {
        delegate?.attachmentWasTouched(self)
    }
}
