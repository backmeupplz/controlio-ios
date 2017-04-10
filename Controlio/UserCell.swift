//
//  UserCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 21/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Material

class UserCell: ASCellNode {
    
    // MARK: - Variables -
    
    var invite: Invite?
    var user: User?
    
    fileprivate var imageNode: ASImageNode!
    fileprivate var nameNode: ASTextNode!
    
    // MARK: - Node life cycle -
    
    required init(with user: User? = nil, invite: Invite? = nil) {
        super.init()
        
        self.user = user
        self.invite = invite
        
        setupStyle()
        setupImageNode()
        nameNode = ASTextNode()
        nameNode.style.flexShrink = 1.0
    }
    
    override func didLoad() {
        super.didLoad()
        
        [imageNode, nameNode]
            .forEach { view.addSubview($0.view) }
        
        configure()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageTextStack = ASStackLayoutSpec(direction: .horizontal,
                                               spacing: 15,
                                               justifyContent: .start,
                                               alignItems: .center,
                                               children: [imageNode, nameNode])
        let insets = EdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return ASInsetLayoutSpec(insets: insets, child: imageTextStack)
    }
    
    // MARK: - General functions -
    
    fileprivate func configure() {
        configureImageNode()
        configureNameNode()
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupStyle() {
        style.minHeight = ASDimensionMakeWithPoints(40)
        backgroundColor = Color.white
    }
    
    fileprivate func setupImageNode() {
        imageNode = ASImageNode()
        imageNode.style.preferredSize = CGSize(width: 30, height: 30)
        imageNode.cornerRadius = 4
        imageNode.clipsToBounds = true
    }
    
    fileprivate func configureImageNode() {
        imageNode.image = R.image.photoBackgroundPlaceholderSmall()
        if let key = invite?.invitee?.profileImageKey ?? user?.profileImageKey {
            imageNode.load(key: key)
        }
    }
    
    fileprivate func configureNameNode() {
        var name = ""
        if let invite = invite {
            name = invite.invitee?.name ?? invite.invitee?.email ?? ""
        } else if let user = user {
            name = user.name ?? user.email
        }
        nameNode.attributedText =
            NSAttributedString(string: name,
                               font: R.font.sFUITextRegular(size: 17),
                               color: Color.controlioBlackText)
    }
}
