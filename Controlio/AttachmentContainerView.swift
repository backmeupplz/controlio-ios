//
//  AttachmentContainerView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import NohanaImagePicker
import Photos


protocol AttachmentContainerViewDelegate: class {
    func closeImagePicker()
}

class AttachmentContainerView: UIView, PickerDelegate {
    
    // MARK: - NohanaImagePickerControllerDelegate -
    
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts: [PHAsset]){
        for image in pickedAssts {
            wrapperView.attachments.append(picker.getAssetUIImage(image))
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
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
}
