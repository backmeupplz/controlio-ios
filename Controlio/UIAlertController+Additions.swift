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
    
    func addCancelButton(title: String = "Cancel") {
        let cancel = UIAlertAction(title: title, style: .Cancel) { action in
            // Do nothing
        }
        addAction(cancel)
    }
    
    func addPopoverSourceView(view: UIView) {
        if let popover = popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
    }
    
    func addDefaultAction(title: String, completion:()->Void) {
        let action = UIAlertAction(title: title, style: .Default) { action in
            completion()
        }
        addAction(action)
    }
}
