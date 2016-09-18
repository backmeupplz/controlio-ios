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
    
    func addCancelButton(_ title: String = "Cancel") {
        let cancel = UIAlertAction(title: title, style: .cancel) { action in
            // Do nothing
        }
        addAction(cancel)
    }
    
    func addPopoverSourceView(_ view: UIView) {
        if let popover = popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
    }
    
    func addDefaultAction(_ title: String, completion:@escaping ()->Void) {
        let action = UIAlertAction(title: title, style: .default) { action in
            completion()
        }
        addAction(action)
    }
}
