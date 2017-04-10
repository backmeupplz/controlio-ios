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
    
    // MARK: - Outlets -
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    
    var delegate: ProjectApproveCellDelegate?
    var invite: Invite! {
        didSet {
            configure()
        }
    }
    
    // MARK: - View Life Cycle -
    
    init(with invite: Invite, delegate: ProjectApproveCellDelegate) {
        super.init()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.setImage(Icon.check, for: .normal)
        checkButton.tintColor = Color.controlioGreen
        crossButton.setImage(Icon.close, for: .normal)
        crossButton.tintColor = Color.controlioGreen
    }
    
    // MARK: - Actions -
    
    @IBAction func checkTouched(_ sender: Any) {
        delegate?.checkTouched(at: self)
    }
    
    @IBAction func crossTouched(_ sender: Any) {
        delegate?.crossTouched(at: self)
    }
    
    // MARK: - Private functions -
    
    fileprivate func configure() {
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
        
        label.text = "\(senderName) \(inviteString) \"\(projectTitle)\""
    }
}
