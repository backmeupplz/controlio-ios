//
//  ProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 13/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Material

enum ProjectCellType {
    case list
    case info
}

protocol ProjectCellDelegate: class {
    func projectPhotoTouched(at node: ProjectCell)
}

class ProjectCell: ASCellNode {
    
    // MARK: - Variables -
    
    weak var delegate: ProjectCellDelegate?
    var project: Project!
    var type = ProjectCellType.list
    
    fileprivate var roundedNode: ASDisplayNode!
    fileprivate var imageNode: ASImageNode!
    fileprivate var dateNode: ASTextNode!
    fileprivate var titleNode: ASTextNode!
    fileprivate var descriptionNode: ASTextNode!
    
    // MARK: - Node life cycle -
    
    required init(with project: Project, type: ProjectCellType, delegate: ProjectCellDelegate? = nil) {
        super.init()
        
        self.project = project
        self.type = type
        self.delegate = delegate
        
        setupStyle()
        createRoundedNode()
        if project.imageKey != nil {
            createImageNode()
        }
        dateNode = ASTextNode()
        titleNode = ASTextNode()
        descriptionNode = ASTextNode()
        
        [roundedNode, dateNode, titleNode, descriptionNode]
            .forEach { addSubnode($0) }
        if project.imageKey != nil {
            addSubnode(imageNode)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        configure()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // [Text nodes] vertical stack
        let textNodes: [ASTextNode] =
            [dateNode, titleNode, descriptionNode]
        let textStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 5,
                                          justifyContent: .spaceBetween,
                                          alignItems: .start,
                                          children: textNodes)
        textStack.style.flexShrink = 1.0
        
        // [Text nodes vertical stack + image] horizontal stack
        var content = textStack
        if project.imageKey != nil {
            content = ASStackLayoutSpec(direction: .horizontal,
                                        spacing: 15,
                                        justifyContent: .start,
                                        alignItems: .start,
                                        children: [imageNode, textStack])
        }
        
        // [[Text nodes vertical stack + image] horizontal stack] insets
        let imageAndTextInsets = EdgeInsets(top: 20, left: 25, bottom: 20, right: 25)
        let imageAndTextInset = ASInsetLayoutSpec(insets: imageAndTextInsets,
                                                  child: content)
        
        // [Rounded node] insets
        let insets = EdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        let roundedNodeInset = ASInsetLayoutSpec(insets: insets, child: roundedNode)
        
        return ASBackgroundLayoutSpec(child: imageAndTextInset, background: roundedNodeInset)
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
    
    fileprivate func createImageNode() {
        imageNode = ASImageNode()
        imageNode.cornerRadius = 4
        imageNode.clipsToBounds = true
        imageNode.style.preferredSize = CGSize(width: 60, height: 60)
        imageNode.contentMode = .scaleAspectFill
        if delegate != nil {
            imageNode.addTarget(self, action: #selector(ProjectCell.photoTapped), forControlEvents: .touchUpInside)
        }
    }
    
    fileprivate func configure() {
        view.alpha = project.isFinished ? 0.5 : 1.0
        configureImageNode()
        configureDateNode()
        configureTitleNode()
        configureDescriptionNode()
    }
    
    fileprivate func configureImageNode() {
        if let key = project.imageKey {
            imageNode.image = R.image.photoBackgroundPlaceholder()
            imageNode.load(key: key)
        }
    }
    
    fileprivate func configureDateNode() {
        var text = ""
        if project.isFinished {
            text = NSLocalizedString("Finished", comment: "finished project cell label")
        } else if let date = project.dateUpdated {
            text = DateFormatter.projectDateString(date)
        }
        dateNode.attributedText =
            NSAttributedString(string: text,
                               font: R.font.sFUIDisplayRegular(size: 12),
                               color: Color.controlioGrayText)
    }
    
    fileprivate func configureTitleNode() {
        titleNode.attributedText =
            NSAttributedString(string: project.title ?? "",
                               font: R.font.sFUIDisplayBold(size: 18),
                               color: Color.controlioBlackText)
        titleNode.maximumNumberOfLines = type == .info ? 0 : 1
    }
    
    fileprivate func configureDescriptionNode() {
        var string = ""
        
        if type == .info, let text = project.projectDescription {
            descriptionNode.alpha = 1
            string = text
        } else if let post = project.lastPost {
            if let text = post.text, let name = post.author.name ?? post.author.email, text.characters.count > 0 {
                descriptionNode.alpha = 1
                string = "\(name): \(text)"
            } else if post.attachments.count > 0 {
                descriptionNode.alpha = 0.5
                let count = post.attachments.count
                if count == 1 {
                    string = String(format: NSLocalizedString("%d attachment", comment: "singular attachments placeholder"), count)
                } else {
                    string = String(format: NSLocalizedString("%d attachments", comment: "plural attachments placeholder"), count)
                }
            }
        } else {
            descriptionNode.alpha = 0.5
            string = NSLocalizedString("Nothing here yet", comment: "project cell placeholder")
        }
        
        descriptionNode.attributedText =
            NSAttributedString(string: string,
                               font: R.font.sFUIDisplayRegular(size: 14),
                               color: Color.controlioBlackText)
        descriptionNode.maximumNumberOfLines = type == .info ? 0 : 3
    }
    
    @objc fileprivate func photoTapped() {
        delegate?.projectPhotoTouched(at: self)
    }
}
