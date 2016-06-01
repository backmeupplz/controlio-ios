//
//  CustomizableImageView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 13/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SDWebImage

class CustomizableImageView: UIImageView {

    // MARK: - Variables -
    
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var shadowColor: UIColor = UIColor.blackColor()
    @IBInspectable var shadowRadius: CGFloat = 0
    @IBInspectable var shadowOpacity: Float = 0
    @IBInspectable var shadowOffset: CGSize = CGSizeZero
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.clearColor()
    var s3Key: String? {
        didSet {
            getImageFromS3()
        }
    }
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundCorners()
        addShadow()
    }
    
    // MARK: - Private Functions -
    
    private func roundCorners() {
        layer.cornerRadius = cornerRadius
    }
    
    private func addShadow() {
        layer.shadowColor = shadowColor.CGColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.CGColor
    }
    
    // Images and S3
    
    private func getImageFromS3() {
        let cache = SDImageCache.sharedImageCache()
        
        if let image = cache.imageFromDiskCacheForKey(s3Key!) {
            print("got image (\(s3Key!)) from memory cache")
            self.image = image
            return
        }
        cache.queryDiskCacheForKey(s3Key) { image, cacheType in
            if let image = image {
                print("got image (\(self.s3Key!)) from disk cache")
                self.image = image
            } else {
                S3.getImage(self.s3Key!) { image, error in
                    if let error = error {
                        PopupNotification.showNotification(error)
                    } else if let image = image {
                        print("got image (\(self.s3Key!)) from internet")
                        cache.storeImage(image, forKey: self.s3Key!)
                        self.image = image
                    }
                }
            }
        }
    }
}
