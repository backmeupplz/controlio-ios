//
//  CatchPhraseView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 05/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class CatchPhraseView: UIScrollView, UIScrollViewDelegate {
    
    // MARK: - Variables -
    
    var labelsText = [String]() {
        didSet {
            setupPageControl()
            addLabels()
        }
    }

    // MARK: - Outlets -
    
    @IBOutlet private weak var pageControl: UIPageControl?
    
    // MARK: - View Life Cycle -

    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
    }
    
    // MARK: - UIScrollViewDelegate -
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl?.currentPage = Int(contentOffset.x / frame.width)
    }
    
    // MARK: - Private Functions -
    
    private func setupPageControl() {
        pageControl?.currentPage = 0
        pageControl?.numberOfPages = labelsText.count
    }
    
    private func addLabels() {
        var previousLabel: UILabel?
        for text in labelsText {
            let label = UILabel()
            label.textAlignment = NSTextAlignment.Center
            label.text = text
            label.numberOfLines = 0
            label.textColor = UIColor.whiteColor()
            label.font = UIFont(name: "SFUIText-Regular", size: 16)
            
            addSubview(label)
            
            label.snp_makeConstraints{ make in
                make.width.equalTo(self).inset(UIEdgeInsetsMake(0, 4, 0, 4))
                make.centerY.equalTo(self)
                if previousLabel != nil {
                    make.left.equalTo(previousLabel!.snp_right).offset(8)
                } else {
                    make.left.equalTo(self).offset(4)
                }
                if text == labelsText.last {
                    make.right.equalTo(self).inset(4)
                }
            }
            previousLabel = label
        }
    }
}
