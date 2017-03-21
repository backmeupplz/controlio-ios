//
//  AttachmentWrapperView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

private let itemSize = CGSize(width: 55, height: 53)

class AttachmentWrapperView: UIView, AttachmentViewDelegate {
    
    // MARK: - Variables -
    
    var preferredMaxLayoutWidth: CGFloat = 0 {
        didSet {
            configureMaxLayoutWidth(oldValue)
        }
    }
    var attachments = [Any]() {
        didSet {
            configureAttachments()
        }
    }
    
    // MARK: - Private Variables -
    
    fileprivate var attachmentViews = [AttachmentView]()
    
    // MARK: - AttachmentViewDelegate -
    
    func attachmentDidTouchCross(_ attachment: AttachmentView) {
        if let key = attachment.imageKey {
            let index = attachments.index(where: { object -> Bool in
                if let object = object as? String {
                    return object == key
                } else {
                    return false
                }
            })
            if let index = index {
                attachments.remove(at: index)
            }
        } else if let image = attachment.image {
            let index = attachments.index(where: { object -> Bool in
                if let object = object as? UIImage {
                    return object == image
                } else {
                    return false
                }
            })
            if let index = index {
                attachments.remove(at: index)
            }
        }
    }
    
    func attachmentWasTouched(_ attachment: AttachmentView) {
        // open attachment
    }
    
    // MARK: - General Functions -
    
    override var intrinsicContentSize : CGSize {
        if attachments.count == 0 || isHidden {
            return CGSize.zero
        }
        var totalRect = CGRect.null
        enumerateItemRects(preferredMaxLayoutWidth) { itemRect in
            totalRect = itemRect.union(totalRect)
        }
        totalRect.size.height = totalRect.size.height + 3
        return totalRect.size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        var index = 0
        enumerateItemRects(bounds.width) { itemRect in
            self.subviews[index].frame = itemRect
            index = index + 1
        }
    }
    
    func configureAttachments() {
        for view in attachmentViews {
            view.removeFromSuperview()
        }
        
        attachmentViews = [AttachmentView]()
        
        for attachment in attachments {
            let attachmentView = AttachmentView.view(self, delegate: self)
            attachmentView.frame = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
            if let image = attachment as? UIImage {
                attachmentView.image = image
            } else if let key = attachment as? String {
                attachmentView.image = nil
                attachmentView.imageKey = key
            }
            attachmentView.translatesAutoresizingMaskIntoConstraints = false
            attachmentViews.append(attachmentView)
        }
        
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configureMaxLayoutWidth(_ oldValue: CGFloat) {
        
        if preferredMaxLayoutWidth == oldValue {
            return
        }
        
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func enumerateItemRects(_ width: CGFloat, closure: (_ itemRect:CGRect)->()) {
        let layoutWidth = max(width, itemSize.width)
        
        var x = CGFloat(0)
        var y = CGFloat(0)
        
        for _ in 0..<attachments.count {
            if x > layoutWidth - itemSize.width {
                y = y + itemSize.height
                x = 0
            }
            
            closure(CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height))
            
            x = x + itemSize.width
        }
    }
    
}
