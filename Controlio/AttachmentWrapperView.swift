//
//  AttachmentWrapperView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

private let itemSize = CGSizeMake(55, 53)

class AttachmentWrapperView: UIView, AttachmentViewDelegate {
    
    // MARK: - Variables -
    
    var preferredMaxLayoutWidth: CGFloat! {
        didSet {
            configureMaxLayoutWidth(oldValue)
        }
    }
    var attachments = [UIImage]() {
        didSet {
            configureAttachments()
        }
    }
    
    // MARK: - Private Variables -
    
    private var attachmentViews = [AttachmentView]()
    
    // MARK: - AttachmentViewDelegate -
    
    func attachmentDidTouchCross(attachment: AttachmentView) {
        
    }
    
    func attachmentWasTouched(attachment: AttachmentView) {
        
    }
    
    // MARK: - General Functions -
    
    override func intrinsicContentSize() -> CGSize {
        if attachments.count == 0 {
            return CGSizeZero
        }
        var totalRect = CGRectNull
        enumerateItemRects(preferredMaxLayoutWidth) { itemRect in
            totalRect = CGRectUnion(itemRect, totalRect)
        }
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
    
    // MARK: - Private Functions -
    
    private func configureMaxLayoutWidth(oldValue: CGFloat) {
        if preferredMaxLayoutWidth == oldValue {
            return
        }
        invalidateIntrinsicContentSize()
    }
    
    private func configureAttachments() {
        for view in attachmentViews {
            view.removeFromSuperview()
        }
        
        attachmentViews = [AttachmentView]()
        
        for attachment in attachments {
            let attachmentView = AttachmentView.view(self, delegate: self)
            attachmentView.frame = CGRectMake(0, 0, itemSize.width, itemSize.height)
            attachmentView.image = attachment
            attachmentView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        invalidateIntrinsicContentSize()
    }
    
    private func enumerateItemRects(width: CGFloat, closure: (itemRect:CGRect)->()) {
        let layoutWidth = max(width, itemSize.width)
        
        var x = CGFloat(0)
        var y = CGFloat(0)
        
        for _ in 0..<attachments.count {
            if x > layoutWidth - itemSize.width {
                y = y + itemSize.height
                x = 0
            }
            
            closure(itemRect: CGRectMake(x, y, itemSize.width, itemSize.height))
            
            x = x + itemSize.width
        }
    }
}
