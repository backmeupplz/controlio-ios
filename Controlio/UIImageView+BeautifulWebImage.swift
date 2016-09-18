//
//  UIImageView+BeautifulWebImage.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func loadURL(_ url: URL?) {
        if (url != nil) {
            self.alpha = CGFloat(0)
            self.sd_setImage(with: url!, completed: { (image, error, type, url) -> Void in
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
}
