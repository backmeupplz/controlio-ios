//
//  InputView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SnapKit
import SlackTextViewController

protocol InputViewDelegate: class {
    func openPickerWithDelegate(delegate: PickerDelegate)
    func closeImagePicker()
}

class InputView: CustomizableView, AttachmentContainerViewDelegate {
    
    // MARK: - Variables -
    
    weak var delegate: InputViewDelegate?
    var shown = false
    
    // MARK: - Outlets -
    
    @IBOutlet private weak var textView: SLKTextView!
    @IBOutlet private weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var attachmentContainerView: AttachmentContainerView!
    
    // MARK: - Class Functions -
    
    class func view(superview: UIView, vc: UIViewController, delegate: InputViewDelegate? = nil) -> InputView {
        let result = NSBundle.mainBundle().loadNibNamed(String(InputView), owner: nil, options: [:]).last as! InputView
        result.delegate = delegate
        
        superview.addSubview(result)
        result.snp_makeConstraints { make in
            make.top.equalTo(superview.snp_bottom)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
        }
        result.alpha = 0.0
        result.layoutIfNeeded()
        
        result.textView.placeholder = "Type new message..."
        result.textView.placeholderColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        result.textView.maxNumberOfLines = 5
        
        result.attachmentContainerView.delegate = result
        
        return result
    }
    
    // MARK: - AttachmentContainerViewDelegate -
    
    func closeImagePicker() {
        delegate?.closeImagePicker()
    }
    
    // MARK: - Actions -
    
    @IBAction func attachmentTouched(sender: AnyObject) {
        delegate?.openPickerWithDelegate(attachmentContainerView)
    }
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subscribeNotifications()
    }
    
    // MARK: - General Functions -
    
    func show() {
        shown = true
        self.snp_remakeConstraints { make in
            make.bottom.equalTo(self.superview!)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
        UIView.animateWithDuration(0.3) {
            self.layoutIfNeeded()
            self.alpha = 1.0
        }
    }

    func hide() {
        shown = false
        textView.resignFirstResponder()
        self.snp_remakeConstraints { make in
            make.top.equalTo(self.superview!.snp_bottom)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
        UIView.animateWithDuration(0.3) {
            self.layoutIfNeeded()
            self.alpha = 0.0
        }
    }
    
    func changeBottomSpacing(spacing: CGFloat) {
        self.snp_remakeConstraints { make in
            make.bottom.equalTo(self.superview!.snp_bottom).inset(spacing)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
    }
    
    // MARK: - Private Functions -
    
    private func subscribeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(InputView.textViewChangedContentSize),
                                                         name: SLKTextViewContentSizeDidChangeNotification,
                                                         object: nil)
    }
    
    private func unsubscribeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func textViewChangedContentSize() {
        if !textView.isExpanding {
            textViewHeight.constant = textView.contentSize.height
            layoutIfNeeded()
        }
    }
}
