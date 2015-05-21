//
//  StatusCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit
import Masonry

class StatusCell: UITableViewCell {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var managerImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var borderedView: UIView!
    
    // MARK: - Public Variables -
    
    var manager: ManagerObject!
    var object: StatusObject! {
        didSet {
            configure()
        }
    }
    
    // MARK: - General Methods -
    
    func configure() {
        if (object.type == StatusType.Status || object.type == StatusType.StatusWithImage) {
            managerImageView.loadURL(manager.image)
        }
        if (object.type == StatusType.StatusWithImage) {
            setupImages()
        }
        statusLabel.text = object.text
    }
    
    func setupImages() {
        var imageView1 = addImageViewWithIndex(0)
        addConstraintsToImageView1(imageView1)
        addButtonToView(imageView1, index: 0)
        
        if (object.attachements!.count > 1) {
            var imageView2 = addImageViewWithIndex(1)
            addConstraintsToImageView2(imageView2, imageView1: imageView1)
            addButtonToView(imageView2, index: 1)
            
            if (self.object.attachements!.count > 2) {
                var imageView3 = addImageViewWithIndex(2)
                addConstraintsToImageView3(imageView3, imageView2: imageView2)
                if (object.attachements!.count > 3) {
                    addPlusLabelToView(imageView3)
                }
                addButtonToView(imageView3, index: 2)
            }
        }
    }
    
    func addImageViewWithIndex(index: Int) -> UIImageView {
        var attachements = object.attachements as [NSURL]!
        var imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.cornerRadius = 6.0
        imageView.loadURL(attachements[index])
        borderedView.addSubview(imageView)
        return imageView
    }
    
    func addConstraintsToImageView1(imageView: UIImageView) {
        imageView.mas_makeConstraints{ make in
            make.height.equalTo()(imageView.mas_width)
            make.left.equalTo()(self.statusLabel.mas_left)
            make.top.equalTo()(self.statusLabel.mas_bottom).offset()(16)
            make.bottom.equalTo()(self.borderedView.mas_bottom).offset()(-16)
            if (self.object.attachements!.count == 1) {
                make.right.equalTo()(self.borderedView.mas_right).offset()(-16)
            }
        }
    }
    
    func addConstraintsToImageView2(imageView: UIImageView, imageView1: UIImageView) {
        imageView.mas_makeConstraints{ make in
            make.height.equalTo()(imageView.mas_width)
            make.left.equalTo()(imageView1.mas_right).offset()(8)
            make.top.equalTo()(imageView1.mas_top)
            make.width.equalTo()(imageView1.mas_width)
            if (self.object.attachements!.count == 2) {
                make.right.equalTo()(self.borderedView.mas_right).offset()(-16)
            }
        }
    }
    
    func addConstraintsToImageView3(imageView: UIImageView, imageView2: UIImageView) {
        imageView.mas_makeConstraints{ make in
            make.height.equalTo()(imageView.mas_width)
            make.left.equalTo()(imageView2.mas_right).offset()(8)
            make.top.equalTo()(imageView2.mas_top)
            make.right.equalTo()(self.borderedView.mas_right).offset()(-16)
            make.width.equalTo()(imageView2.mas_width)
        }
    }
    
    func addPlusLabelToView(view: UIView) {
        var label = UILabel()
        self.borderedView.addSubview(label)
        label.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
        label.textColor = UIColor.whiteColor()
        label.text = "+\(object.attachements!.count-3)"
        label.mas_makeConstraints{ make in
            make.edges.equalTo()(view)
        }
        label.textAlignment = NSTextAlignment.Center
        label.layer.cornerRadius = 6.0
        label.layer.masksToBounds = true
    }
    
    func addButtonToView(view: UIView, index: Int) {
        var button = UIButton()
        self.borderedView.addSubview(button)
        button.mas_makeConstraints{ make in
            make.edges.equalTo()(view)
        }
        button.tag = index
        button.addTarget(self, action: "openAttachment:", forControlEvents: .TouchUpInside)
    }
    
    func openAttachment(sender: UIButton) {
        var index = sender.tag
        println("Touched image #\(index)")
    }
}