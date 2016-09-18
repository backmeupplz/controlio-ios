//
//  PostCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

protocol PostCellDelegate: class {
    func openAttachment(_ index: Int, post: Post)
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
    
    @IBOutlet fileprivate weak var managerImageView: CustomizableImageView!
    @IBOutlet fileprivate weak var managerNameLabel: UILabel!
    
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var postLabel: UILabel!
    
    @IBOutlet fileprivate weak var separator: UIView!
    @IBOutlet fileprivate weak var clipImageView: UIImageView!
    
    @IBOutlet fileprivate var attachmentImageViews: [UIImageView]!
    @IBOutlet fileprivate var attachmentButtons: [UIButton]!
    
    @IBOutlet fileprivate weak var gradientAttachmentView: UIView!
    @IBOutlet weak var extraAttachmentNumberLabel: UILabel!
    
    @IBOutlet fileprivate weak var postLabelBottom: NSLayoutConstraint!
    
    // MARK: - Actions -
    
    @IBAction func attachmentTouched(_ sender: UIButton) {
        delegate?.openAttachment(sender.tag, post: post)
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configure() {
        managerImageView.loadURL(post.manager.image)
        managerNameLabel.text = post.manager.name
        dateLabel.text = DateFormatter.projectDateString(post.date)
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
                attachmentImageViews[number].isHidden = true
                attachmentButtons[number].isHidden = true
            }
        }
        
        if post.attachments.count > 3 {
            gradientAttachmentView.isHidden = false
            extraAttachmentNumberLabel.isHidden = false
            extraAttachmentNumberLabel.text = "+\(post.attachments.count-3)"
        } else {
            gradientAttachmentView.isHidden = true
            extraAttachmentNumberLabel.isHidden = true
        }
    }
    
    fileprivate func hideAttachments(_ hide: Bool) {
        var viewsToHide: [UIView] = [separator, clipImageView, gradientAttachmentView, extraAttachmentNumberLabel]
        for imageView in attachmentImageViews {
            viewsToHide.append(imageView)
        }
        for button in attachmentButtons {
            viewsToHide.append(button)
        }
        for view in viewsToHide {
            view.isHidden = hide
        }
        postLabelBottom.priority = hide ? 750 : 250
    }
}
