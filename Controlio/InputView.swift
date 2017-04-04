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
import CLTokenInputView

protocol InputViewDelegate: class {
    func openPicker(with delegate: AllPickerDelegate, sender: UIView)
    func closeImagePicker()
    func shouldAddPost(text: String, attachments: [Any])
    func shouldChangeStatus(text: String)
    func shouldEditPost(post: Post, text: String, attachments: [Any])
}

class InputView: UIView, AttachmentContainerViewDelegate {
    
    // MARK: - Variables -
    
    var project: Project!
    weak var delegate: InputViewDelegate?
    var shown = false
    
    var post: Post? {
        didSet {
            configureForEditting()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet fileprivate weak var textView: SLKTextView!
    @IBOutlet fileprivate weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var attachmentContainerView: AttachmentContainerView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var clipImage: UIImageView!
    @IBOutlet weak var clipButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var attachmentCount: Int {
        return attachmentContainerView.wrapperView.attachments.count
    }
    
    // MARK: - Class Functions -
    
    class func view(_ superview: UIView, vc: UIViewController, delegate: InputViewDelegate? = nil, project: Project) -> InputView {
        let result = Bundle.main.loadNibNamed("InputView", owner: nil, options: [:])?.last as! InputView
        result.delegate = delegate
        
        superview.addSubview(result)
        result.snp.makeConstraints { make in
            make.top.equalTo(superview.snp.bottom)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
        }
        result.alpha = 0.0
        result.layoutIfNeeded()
        
        result.textView.placeholder = NSLocalizedString("Type new message...", comment: "Input view placeholder")
        result.textView.placeholderColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        result.textView.maxNumberOfLines = 5
        
        result.attachmentContainerView.delegate = result
        result.project = project
        
        return result
    }
    
    // MARK: - AttachmentContainerViewDelegate -
    
    func closeImagePicker() {
        delegate?.closeImagePicker()
    }
    
    // MARK: - Actions -
    
    @IBAction func attachmentTouched(_ sender: AnyObject) {
        delegate?.openPicker(with: attachmentContainerView, sender: sender as! UIView)
    }
    
    @IBAction func sendTouched(_ sender: AnyObject) {
        guard project.canEdit else {
            return 
        }
        textView.resignFirstResponder()
        if let post = post {
            delegate?.shouldEditPost(post: post, text: textView.text, attachments: attachmentContainerView.wrapperView.attachments)
            return
        }
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let text = textView.text ?? ""
            let attachments = attachmentContainerView.wrapperView.attachments
            delegate?.shouldAddPost(text: text, attachments: attachments)
        case 1:
            let text = textView.text ?? ""
            delegate?.shouldChangeStatus(text: text)
        default:
            break
        }
    }
    
    @IBAction func cancelTouched(_ sender: AnyObject) {
        post = nil
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        sendButton.setTitle(index == 0 ? NSLocalizedString("Send", comment: "Input view button") : NSLocalizedString("Save", comment: "Input view button"), for: .normal)
        textView.placeholder = index == 0 ? NSLocalizedString("Type new message...", comment: "Input view placeholder") : NSLocalizedString("Type new status...", comment: "Input view placeholder")
        
        clipImage.isHidden = index != 0
        clipButton.isEnabled = index == 0
        attachmentContainerView.wrapperView.isHidden = index != 0
        
        setNeedsLayout()
    }
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subscribe()
    }
    
    deinit {
        unsubscribe()
    }
    
    // MARK: - General Functions -
    
    func clean() {
        textView.text = ""
        attachmentContainerView.wrapperView.attachments = []
    }
    
    func show() {
        shown = true
        self.snp.remakeConstraints { make in
            make.bottom.equalTo(self.superview!)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.alpha = 1.0
        }) 
    }

    func hide() {
        shown = false
        textView.resignFirstResponder()
        self.snp.remakeConstraints { make in
            make.top.equalTo(self.superview!.snp.bottom)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.alpha = 0.0
        }) 
    }
    
    func changeBottomSpacing(_ spacing: CGFloat) {
        self.snp.remakeConstraints { make in
            make.bottom.equalTo(self.superview!.snp.bottom).inset(spacing)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
    }
    
    // MARK: - Private Functions -
    
    fileprivate func subscribe() {
        subscribe(to: [
            .SLKTextViewContentSizeDidChange:
                #selector(InputView.textViewChangedContentSize)
        ])
    }
    
    @objc fileprivate func textViewChangedContentSize() {
        if !textView.isExpanding {
            textViewHeight.constant = textView.contentSize.height
            layoutIfNeeded()
        }
    }
    
    fileprivate func configureForEditting() {
        if let post = post {
            segmentedControl.isHidden = true
            cancelButton.isHidden = false
            textView.text = post.text
            attachmentContainerView.wrapperView.attachments = post.attachments
            clipImage.isHidden = post.type == .status
            clipButton.isEnabled = post.type != .status
        } else {
            segmentedControl.isHidden = false
            cancelButton.isHidden = true
            textView.text = ""
            attachmentContainerView.wrapperView.attachments = []
            clipImage.isHidden = segmentedControl.selectedSegmentIndex != 0
            clipButton.isEnabled = segmentedControl.selectedSegmentIndex == 0
        }
    }
}
