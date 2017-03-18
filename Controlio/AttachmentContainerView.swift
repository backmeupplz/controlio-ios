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

    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    // MARK: - NohanaImagePickerControllerDelegate -
    
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController){
        print("cancel")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts: [PHAsset]){
        print("complited")
        for image in pickedAssts {
            wrapperView.attachments.append(getAssetThumbnail(asset: image))
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
    
    // MARK: - UIImagePickerControllerDelegate -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            wrapperView.attachments.append(pickedImage)
        }
        
        delegate?.closeImagePicker()
    }
}
