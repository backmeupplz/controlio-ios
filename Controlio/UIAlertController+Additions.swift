//
//  UIAlertController+CancelButton.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    // MARK: - General Functions -
    
    convenience init(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .actionSheet, sourceView: UIView? = nil) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        if let sourceView = sourceView {
            add(sourceView: sourceView)
        }
    }
    
    func addCancelButton(_ title: String = NSLocalizedString("Cancel", comment: "Cancel button on alert views")) {
        let cancel = UIAlertAction(title: title, style: .cancel) { action in
            // Do nothing
        }
        addAction(cancel)
    }
    
    func add(sourceView: UIView) {
        if let popover = popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
    }
    
    func add(action title: String, style: UIAlertActionStyle = .default, completion:@escaping ()->Void) {
        let action = UIAlertAction(title: title, style: style) { action in
            completion()
        }
        addAction(action)
    }
}
