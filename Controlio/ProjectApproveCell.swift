//
//  ProjectApproveCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 14/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material
import AsyncDisplayKit

protocol ProjectApproveCellDelegate {
    func checkTouched(at cell: ProjectApproveCell)
    func crossTouched(at cell: ProjectApproveCell)
}

class ProjectApproveCell: ASCellNode {
    
    // MARK: - Variables -
    
    var delegate: ProjectApproveCellDelegate?
    var invite: Invite!
    
    var titleNode: ASTextNode!
    var checkNode: ASButtonNode!
    var crossNode: ASButtonNode!
    
    // MARK: - Node Life Cycle -
    
    init(with invite: Invite, delegate: ProjectApproveCellDelegate) {
        super.init()
        
        self.invite = invite
        self.delegate = delegate
        
        createTitleNode()
        createCheckNode()
        createCrossNode()
    }
    
    override func didLoad() {
        super.didLoad()
        
        [titleNode, checkNode, crossNode]
            .forEach { view.addSubview($0.view) }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let horizontal = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: 8,
                                           justifyContent: .start,
                                           alignItems: .center,
                                           children: [titleNode, checkNode, crossNode])
        horizontal.style.flexShrink = 1.0
        let insets = EdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return ASInsetLayoutSpec(insets: insets, child: horizontal)
    }
    
    // MARK: - Actions -
    
    func checkTouched() {
        delegate?.checkTouched(at: self)
    }
    
    func crossTouched() {
        delegate?.crossTouched(at: self)
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupStyle() {
        style.minHeight = ASDimensionMakeWithPoints(60)
        backgroundColor = Color.controlioTableBackground
        selectionStyle = .none
    }
    
    fileprivate func createTitleNode() {
        let senderName = invite.sender?.name ?? invite.sender?.email ?? ""
        var inviteString = ""
        switch invite.type {
        case .manage:
            inviteString = "invited you to manage"
        case .own:
            inviteString = "invited you as an owner to"
        case .client:
            inviteString = "invited you as a client to"
        }
        let projectTitle = invite.project!.title ?? ""
        
        let text = "\(senderName) \(inviteString) \"\(projectTitle)\""
        
        titleNode = ASTextNode()
        titleNode.maximumNumberOfLines = 0
        titleNode.attributedText =
            NSAttributedString(string: text,
                               font: R.font.sFUIDisplayRegular(size: 14),
                               color: Color.controlioBlackText)
        titleNode.style.flexShrink = 1.0
    }
    
    fileprivate func createCheckNode() {
        checkNode = ASButtonNode()
        checkNode.setImage(Icon.check, for: .normal)
        checkNode.tintColor = Color.controlioGreen
        checkNode.style.preferredSize = CGSize(width: 30, height: 30)
        checkNode.addTarget(self, action: #selector(ProjectApproveCell.checkTouched), forControlEvents: .touchUpInside)
    }
    
    fileprivate func createCrossNode() {
        crossNode = ASButtonNode()
        crossNode.setImage(Icon.close, for: .normal)
        crossNode.tintColor = Color.controlioGreen
        crossNode.style.preferredSize = CGSize(width: 30, height: 30)
        crossNode.addTarget(self, action: #selector(ProjectApproveCell.crossTouched), forControlEvents: .touchUpInside)
    }
}
