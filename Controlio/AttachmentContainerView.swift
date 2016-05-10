//
//  AttachmentContainerView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class AttachmentContainerView: UIView {
    
    // MARK: - Outlets -
    
    @IBOutlet private weak var wrapperView: AttachmentWrapperView!
    
    // MARK: - View Life Cycle -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        wrapperView.preferredMaxLayoutWidth = wrapperView.frame.width
        super.layoutSubviews()
    }
}
