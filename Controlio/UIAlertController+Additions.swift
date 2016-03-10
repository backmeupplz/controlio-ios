//
//  UIAlertController+CancelButton.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addCancelButton() {
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { action in
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
