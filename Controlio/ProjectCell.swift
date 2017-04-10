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

class ProjectCell: ASCellNode {
    
    // MARK: - Variables -
    
    var project: Project!
    var type = ProjectCellType.list
    
    fileprivate var roundedNode: ASDisplayNode!
    fileprivate var imageNode: ASImageNode!
    fileprivate var dateNode: ASTextNode!
    fileprivate var titleNode: ASTextNode!
    fileprivate var descriptionNode: ASTextNode!
    
    // MARK: - Node life cycle -
    
    required init(with project: Project, type: ProjectCellType) {
        super.init()
        
        self.project = project
        self.type = type
        
        setupStyle()
        createRoundedNode()
        if project.imageKey != nil {
            createImageNode()
        }
        dateNode = ASTextNode()
        titleNode = ASTextNode()
        descriptionNode = ASTextNode()
    }
    
    override func didLoad() {
        super.didLoad()
        
        [roundedNode, dateNode, titleNode, descriptionNode]
            .forEach { view.addSubview($0.view) }
        if project.imageKey != nil {
            view.addSubview(imageNode.view)
        }
        
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
            text = "Finished"
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
        if type == .info {
            if let text = project.projectDescription {
                descriptionNode.alpha = 1
                string = text
            } else if let text = project.lastPost?.text {
                descriptionNode.alpha = 1
                string = text
            } else {
                descriptionNode.alpha = 0.5
                string = "Nothing here yet"
            }
        } else {
            if let text = project.lastPost?.text {
                descriptionNode.alpha = 1
                string = text
            } else {
                descriptionNode.alpha = 0.5
                string = "Nothing here yet"
            }
        }
        descriptionNode.attributedText =
            NSAttributedString(string: string,
                               font: R.font.sFUIDisplayRegular(size: 14),
                               color: Color.controlioBlackText)
        descriptionNode.maximumNumberOfLines = type == .info ? 0 : 2
    }
}
