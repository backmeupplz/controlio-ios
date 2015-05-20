//
//  UIImageView+BeautifulWebImage.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadURL(url: NSURL?) {
        if (url != nil) {
            self.alpha = CGFloat(0)
            self.sd_setImageWithURL(url!, completed: { (image, error, type, url) -> Void in
                if (type != .Memory) {
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.alpha = CGFloat(1)
                    })
                } else {
                    self.alpha = CGFloat(1)
                }
            })
        }
    }
}