//
//  ProjectApproveCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 14/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

protocol ProjectApproveCellDelegate {
    func checkTouched(at cell: ProjectApproveCell)
    func crossTouched(at cell: ProjectApproveCell)
}

class ProjectApproveCell: UITableViewCell {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    
    var delegate: ProjectApproveCellDelegate?
    var project: Project! {
        didSet {
            configure()
        }
    }
    
    // MARK: - View Life Cycle -

    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.setImage(Icon.check, for: .normal)
        checkButton.tintColor = Color.controlioGreen()
        crossButton.setImage(Icon.close, for: .normal)
        crossButton.tintColor = Color.controlioGreen()
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
        label.text = ""
        guard let type = project.createdType else { return }
        if type == .clientCreated {
            guard let name = project.clients.first?.name ?? project.clients.first?.email,
                let title = project.title else { return }
            label.text = "\(name) invited you as a manager to \"\(title)\". Would you like to accept the invite?"
        } else {
            guard let name = project.owner?.name ?? project.owner?.email,
                let title = project.title else { return }
            label.text = "\(name) invited you as a client to \"\(title)\". Would you like to accept the invite?"
        }
    }
}
