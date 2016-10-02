//
//  ImageGallery.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 01/10/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import SDWebImage

class ImageGallery: SKPhotoDownloader {
    func load(key: String, completion:@escaping (UIImage?, NSError?)->()) {
        if let imageFromMemoryCache = SDImageCache.shared().imageFromMemoryCache(forKey: key) {
            completion(imageFromMemoryCache, nil)
        } else {
            SDImageCache.shared().queryDiskCache(forKey: key)
            { image, cacheType in
                if let image = image {
                    completion(image, nil)
                } else {
                    S3.getImage(key)
                    { image, error in
                        if let error = error {
                            completion(nil, NSError(domain: error, code: 500, userInfo: nil))
                        } else {
                            SDImageCache.shared().store(image, forKey: key)
                            completion(image, nil)
                        }
                    }
                }
            }
        }
    }
    func showGallery(atViewController: UIViewController, index: Int, imageKeys: [String], fromView: UIView) {
        let images = imageKeys.map { SKPhoto.photo(key: $0, delegate: self) }
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(index)
        atViewController.present(browser, animated: true, completion: {})
    }
}
