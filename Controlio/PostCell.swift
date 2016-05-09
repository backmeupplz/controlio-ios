//
//  PostCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

protocol PostCellDelegate: class {
    func openAttachment(index: Int, post: Post)
}

class PostCell: UITableViewCell {
    
    // MARK: - Variables -
    
    var post: Post! {
        didSet {
            configure()
        }
    }
    weak var delegate: PostCellDelegate?
    
    // MARK: - Outlets -
    
    @IBOutlet private weak var managerImageView: CustomizableImageView!
    @IBOutlet private weak var managerNameLabel: UILabel!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var postLabel: UILabel!
    
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var clipImageView: UIImageView!
    
    @IBOutlet private var attachmentImageViews: [UIImageView]!
    @IBOutlet private var attachmentButtons: [UIButton]!
    
    @IBOutlet private weak var gradientAttachmentView: UIView!
    @IBOutlet weak var extraAttachmentNumberLabel: UILabel!
    
    @IBOutlet private weak var postLabelBottom: NSLayoutConstraint!
    
    // MARK: - Actions -
    
    @IBAction func attachmentTouched(sender: UIButton) {
        delegate?.openAttachment(sender.tag, post: post)
    }
    
    // MARK: - Private Functions -
    
    private func configure() {
        managerImageView.loadURL(post.manager.image)
        managerNameLabel.text = post.manager.name
        dateLabel.text = NSDateFormatter.projectDateString(post.date)
        postLabel.text = post.text
        
        if post.attachments.count <= 0 {
            hideAttachments(true)
            return
        }
        
        hideAttachments(false)
        
        for number in 0...2 {
            if number < post.attachments.count {
                attachmentImageViews[number].loadURL(post.attachments[number])
            } else {
                attachmentImageViews[number].hidden = true
                attachmentButtons[number].hidden = true
            }
        }
        
        if post.attachments.count > 3 {
            gradientAttachmentView.hidden = false
            extraAttachmentNumberLabel.hidden = false
            extraAttachmentNumberLabel.text = "+\(post.attachments.count-3)"
        } else {
            gradientAttachmentView.hidden = true
            extraAttachmentNumberLabel.hidden = true
        }
    }
    
    private func hideAttachments(hide: Bool) {
        var viewsToHide: [UIView] = [separator, clipImageView, gradientAttachmentView, extraAttachmentNumberLabel]
        for imageView in attachmentImageViews {
            viewsToHide.append(imageView)
        }
        for button in attachmentButtons {
            viewsToHide.append(button)
        }
        for view in viewsToHide {
            view.hidden = hide
        }
        postLabelBottom.priority = hide ? 750 : 250
    }
}
