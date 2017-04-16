//
//  ImageView+Network.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import SnapKit
import AsyncDisplayKit

extension UIImageView {
    func load(key: String?) {
        if let key = key {
            image = nil
            if let imageFromMemoryCache = SDImageCache.shared().imageFromMemoryCache(forKey: key) {
                image = imageFromMemoryCache
            } else {
                let ai = greenActivityIndicator()
                add(activityIndicator: ai)
                
                SDImageCache.shared().queryCacheOperation(forKey: key)
                { image, data, cacheType in
                    if let image = image {
                        self.remove(activityIndicator: ai)
                        self.image = image
                    } else {
                        S3.getImage(key)
                        { image, error in
                            if let error = error {
                                self.remove(activityIndicator: ai)
                                PopupNotification.show(notification: error)
                            } else {
                                self.remove(activityIndicator: ai)
                                SDImageCache.shared().store(image, forKey: key)
                                self.image = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    func load(url: URL?) {
        if let url = url {
            self.alpha = CGFloat(0)
            self.sd_setImage(with: url, completed: { (image, error, type, url) -> Void in
                if (type != .memory) {
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.alpha = CGFloat(1)
                    })
                } else {
                    self.alpha = CGFloat(1)
                }
            })
        }
    }
    
    fileprivate func greenActivityIndicator() -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.color = UIColor.controlioGreen
        return ai
    }
    
    fileprivate func add(activityIndicator: UIActivityIndicatorView) {
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.snp.makeConstraints
        { make in
            make.center.equalTo(self)
        }
    }
    
    fileprivate func remove(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.removeFromSuperview()
    }
}

extension ASImageNode {
    func load(key: String?) {
        if let key = key {
            image = nil
            if let imageFromMemoryCache = SDImageCache.shared().imageFromMemoryCache(forKey: key) {
                image = imageFromMemoryCache
            } else {
                let ai = greenActivityIndicator()
                add(activityIndicator: ai)
                SDImageCache.shared().queryCacheOperation(forKey: key)
                { image, data, cacheType in
                    if let image = image {
                        self.remove(activityIndicator: ai)
                        self.image = image
                    } else {
                        S3.getImage(key)
                        { image, error in
                            self.remove(activityIndicator: ai)
                            if let error = error {
                                PopupNotification.show(notification: error)
                            } else {
                                SDImageCache.shared().store(image, forKey: key)
                                self.image = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func greenActivityIndicator() -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.color = UIColor.controlioGreen
        return ai
    }
    
    fileprivate func add(activityIndicator: UIActivityIndicatorView) {
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: style.preferredSize.width/2, y: style.preferredSize.height/2)
        activityIndicator.startAnimating()
    }
    
    fileprivate func remove(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.removeFromSuperview()
    }
}
