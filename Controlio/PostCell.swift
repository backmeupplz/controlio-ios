//
//  PostCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Material

protocol PostCellDelegate: class {
    func openAttachment(at index: Int, post: Post, fromView: UIView)
    func edit(post: Post, cell: PostCell)
    func open(user: User)
}

class PostCell: ASCellNode {
    
    // MARK: - Variables -
    
    var post: Post!
    weak var delegate: PostCellDelegate?
    var longPressGR: UILongPressGestureRecognizer?
    
    fileprivate var roundedNode: ASDisplayNode!
    fileprivate var managerImageNode: ASImageNode!
    fileprivate var dateNode: ASTextNode!
    fileprivate var managerNameNode: ASTextNode!
    fileprivate var textNode: ASTextNode!
    
    fileprivate var separatorNode: ASDisplayNode!
    fileprivate var clipImageNode: ASImageNode!
    fileprivate var firstAttachmentNode: ASImageNode!
    fileprivate var secondAttachmentNode: ASImageNode!
    fileprivate var thirdAttachmentNode: ASImageNode!
    fileprivate var attachmentGradientNode: ASDisplayNode!
    fileprivate var extraAttachmentsNode: ASTextNode!
    
    // MARK: - Node life cycle -
    
    required init(with post: Post, delegate: PostCellDelegate) {
        super.init()
        
        self.post = post
        self.delegate = delegate
        
        setupStyle()
        createRoundedNode()
        createManagerImageNode()
        createDateNode()
        createManagerNameNode()
        createTextNode()
        if post.attachments.count > 0 {
            createSeparatorNode()
            createClipImageNode()
            createAttachmentNodes()
            if post.attachments.count > 3 {
                createAttachmentGradientNode()
                createExtraAttachmentNode()
            }
        }
        
        var nodes: [ASDisplayNode] = [roundedNode, managerImageNode, dateNode, managerNameNode, textNode]
        
        if post.attachments.count > 0 {
            nodes.append(separatorNode)
            nodes.append(clipImageNode)
            nodes.append(firstAttachmentNode)
        }
        if post.attachments.count > 1 {
            nodes.append(secondAttachmentNode)
        }
        if post.attachments.count > 2 {
            nodes.append(thirdAttachmentNode)
        }
        if post.attachments.count > 3 {
            nodes.append(attachmentGradientNode)
            nodes.append(extraAttachmentsNode)
        }
        
        nodes.forEach { addSubnode($0) }
    }
    
    override func didLoad() {
        super.didLoad()
        
        configureManagerImageNode()
        if post.attachments.count > 0 {
            configureAttachmentNodes()
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textStack =
            ASStackLayoutSpec(direction: .vertical,
                              spacing: 6,
                              justifyContent: .start,
                              alignItems: .start,
                              children: [dateNode, managerNameNode, textNode])
        textStack.style.flexShrink = 1.0
        let imageTextStack =
            ASStackLayoutSpec(direction: .horizontal,
                              spacing: 15,
                              justifyContent: .start,
                              alignItems: .start,
                              children: [managerImageNode, textStack])
        
        var main: [ASLayoutElement] = [imageTextStack]
        if post.attachments.count > 0 {
            
            let separatorInsets =
                ASInsetLayoutSpec(insets:
                    EdgeInsets(top: 0, left: 75, bottom: 0, right: 0),
                                  child: separatorNode)
            main.append(separatorInsets)
            main.append(attachmentHorizontalStack())
        }
        let mainVerticalStack = ASStackLayoutSpec(direction: .vertical,
                                                  spacing: 12,
                                                  justifyContent: .start,
                                                  alignItems: .stretch,
                                                  children: main)
        let insets = EdgeInsets(top: 20, left: 25, bottom: 20, right: 25)
        let mainInset = ASInsetLayoutSpec(insets: insets,
                                          child: mainVerticalStack)
        
        // [Rounded node] insets
        let roundedNodeInsets = EdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        let roundedNodeInset = ASInsetLayoutSpec(insets: roundedNodeInsets, child: roundedNode)
        
        return ASBackgroundLayoutSpec(child: mainInset, background: roundedNodeInset)
    }
    
    // MARK: - Actions -
    
    func attachment1Touched() {
        delegate?.openAttachment(at: 0, post: post, fromView: firstAttachmentNode.view)
    }
    
    func attachment2Touched() {
        delegate?.openAttachment(at: 1, post: post, fromView: secondAttachmentNode.view)
    }
    
    func attachment3Touched() {
        delegate?.openAttachment(at: 2, post: post, fromView: thirdAttachmentNode.view)
    }
    
    func managerTouched() {
        delegate?.open(user: post.author)
    }
    
    // MARK: - Private Functions -
    
    fileprivate func setupStyle() {
        style.minHeight = ASDimensionMakeWithPoints(100)
        backgroundColor = Color.controlioTableBackground
        selectionStyle = .none
    }
    
    fileprivate func createRoundedNode() {
        roundedNode = ASDisplayNode()
        roundedNode.backgroundColor = Color.white
        roundedNode.cornerRadius = 6
    }
    
    fileprivate func createManagerImageNode() {
        managerImageNode = ASImageNode()
        managerImageNode.cornerRadius = 4
        managerImageNode.clipsToBounds = true
        managerImageNode.style.preferredSize = CGSize(width: 60, height: 60)
        managerImageNode.contentMode = .scaleAspectFill
    }
    
    fileprivate func createDateNode() {
        dateNode = ASTextNode()
        
        var text = DateFormatter.projectDateString(post.dateCreated) 
        if post.isEdited {
            text = "(edited) \(text)"
        }
        dateNode.attributedText =
            NSAttributedString(string: text,
                               font: R.font.sFUIDisplayRegular(size: 12),
                               color: Color.controlioGrayText)
    }
    
    fileprivate func createManagerNameNode() {
        managerNameNode = ASTextNode()
        
        let text = post.author.name ?? post.author.email ?? ""
        
        managerNameNode.attributedText =
            NSAttributedString(string: text,
                               font: R.font.sFUIDisplayMedium(size: 14),
                               color: Color.controlioBlackText)
    }
    
    fileprivate func createTextNode() {
        textNode = ASTextNode()
        
        var text: String = post.text
        if post.type == .status {
            text = NSLocalizedString("Status changed: \(text)", comment: "post cell status text")
        }
        
        textNode.attributedText =
            NSAttributedString(string: text,
                               font: R.font.sFUITextLight(size: 14),
                               color: Color.controlioBlackText)
    }
    
    fileprivate func configureManagerImageNode() {
        managerImageNode.image = R.image.photoBackgroundPlaceholder()
        if let managerImageKey = post.author.profileImageKey {
            managerImageNode.load(key: managerImageKey)
        }
        managerImageNode.addTarget(self, action: #selector(PostCell.managerTouched), forControlEvents: .touchUpInside)
    }
    
    fileprivate func createSeparatorNode() {
        separatorNode = ASDisplayNode()
        separatorNode.backgroundColor = Color.controlioTableBackground
        separatorNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake("100%"), height: ASDimensionMakeWithPoints(1))
    }
    
    fileprivate func createClipImageNode() {
        clipImageNode = ASImageNode()
        clipImageNode.style.preferredSize = CGSize(width: 20, height: 12)
        clipImageNode.contentMode = .scaleAspectFit 
        clipImageNode.image = R.image.clip()
    }
    
    fileprivate func createAttachmentNodes() {
        if post.attachments.count > 0 {
            firstAttachmentNode = ASImageNode()
            firstAttachmentNode.cornerRadius = 4
            firstAttachmentNode.clipsToBounds = true
            firstAttachmentNode.style.preferredSize = CGSize(width: 60, height: 60)
            firstAttachmentNode.contentMode = .scaleAspectFill
            firstAttachmentNode.addTarget(self, action: #selector(PostCell.attachment1Touched), forControlEvents: .touchUpInside)
        }
        if post.attachments.count > 1 {
            secondAttachmentNode = ASImageNode()
            secondAttachmentNode.cornerRadius = 4
            secondAttachmentNode.clipsToBounds = true
            secondAttachmentNode.style.preferredSize = CGSize(width: 60, height: 60)
            secondAttachmentNode.contentMode = .scaleAspectFill
            secondAttachmentNode.addTarget(self, action: #selector(PostCell.attachment2Touched), forControlEvents: .touchUpInside)
        }
        if post.attachments.count > 2 {
            thirdAttachmentNode = ASImageNode()
            thirdAttachmentNode.cornerRadius = 4
            thirdAttachmentNode.clipsToBounds = true
            thirdAttachmentNode.style.preferredSize = CGSize(width: 60, height: 60)
            thirdAttachmentNode.contentMode = .scaleAspectFill
            thirdAttachmentNode.addTarget(self, action: #selector(PostCell.attachment3Touched), forControlEvents: .touchUpInside)
        }
    }
    
    fileprivate func configureAttachmentNodes() {
        if post.attachments.count > 0 {
            firstAttachmentNode.load(key: post.attachments[0])
        }
        if post.attachments.count > 1 {
            secondAttachmentNode.load(key: post.attachments[1])
        }
        if post.attachments.count > 2 {
            thirdAttachmentNode.load(key: post.attachments[2])
        }
    }
    
    fileprivate func createAttachmentGradientNode() {
        attachmentGradientNode = ASDisplayNode(viewBlock: { () -> UIView in
            return GradientView()
        })
        attachmentGradientNode.cornerRadius = 4
        attachmentGradientNode.clipsToBounds = true
        attachmentGradientNode.alpha = 0.85
        attachmentGradientNode.isUserInteractionEnabled = false
    }
    
    fileprivate func createExtraAttachmentNode() {
        extraAttachmentsNode = ASTextNode()
        let color = Color(white: 1.0, alpha: 1.0)
        extraAttachmentsNode.attributedText =
            NSAttributedString(string: "+\(post.attachments.count-3)",
                               font: R.font.sFUIDisplayRegular(size: 17),
                               color: color)
        extraAttachmentsNode.isUserInteractionEnabled = false
    }
    
    fileprivate func attachmentHorizontalStack() -> ASLayoutElement {
        var children: [ASLayoutElement] = []
        
        children.append(clipInsets())
        
        if post.attachments.count > 0 {
            children.append(firstAttachmentNode)
        }
        if post.attachments.count > 1 {
            children.append(secondAttachmentNode)
        }
        if post.attachments.count > 3 {
            let overlay = ASOverlayLayoutSpec(child: thirdAttachmentNode, overlay: attachmentGradientNode)
            let textStack = ASStackLayoutSpec(direction: .horizontal,
                                              spacing: 0,
                                              justifyContent: .center,
                                              alignItems: .center,
                                              children: [extraAttachmentsNode])
            let textOverlay = ASOverlayLayoutSpec(child: overlay, overlay: textStack)
            children.append(textOverlay)
        } else if post.attachments.count > 2 {
            children.append(thirdAttachmentNode)
        }
        
        return ASStackLayoutSpec(direction: .horizontal,
                                 spacing: 15,
                                 justifyContent: .start,
                                 alignItems: .start,
                                 children: children)
    }
    
    fileprivate func clipInsets() -> ASLayoutElement {
        let insets = EdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        return ASInsetLayoutSpec(insets: insets, child: clipImageNode)
    }
    
    @objc fileprivate func longPressed() {
        delegate?.edit(post: post, cell: self)
    }
}
