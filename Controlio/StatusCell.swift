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
import MWPhotoBrowser

class StatusCell: UITableViewCell, MWPhotoBrowserDelegate {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var managerImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var borderedView: UIView!
    
    weak var delegate: StatusesViewController!
    
    var imageView1: UIImageView!
    var imageView2: UIImageView?
    var imageView3: UIImageView?
    
    var plusLabel: UILabel?
    
    var button1: UIButton!
    var button2: UIButton?
    var button3: UIButton?
    
    var photos: [MWPhoto]!
    
    // MARK: - Public Variables -
    
    var manager: ManagerObject!
    var object: StatusObject! {
        didSet {
            configure()
        }
    }
    
    // MARK: - MWPhotoBrowserDelegate -
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(photos.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        if (Int(index) < photos.count) {
            return photos[Int(index)];
        } else {
            return nil;
        }
    }
    
    // MARK: - General Methods -
    
    func configure() {
//        if (object.type == StatusType.Status || object.type == StatusType.StatusWithImage) {
//            managerImageView.loadURL(manager.image)
//        }
//        if (object.type == StatusType.StatusWithImage) {
//            setupImages()
//        }
        statusLabel.text = object.text
    }
    
    func setupImages() {
        removePrevViews()
        
        imageView1 = addImageViewWithIndex(0)
        addConstraintsToImageView1(imageView1)
        addButtonToView(imageView1, index: 0)
        
        if (object.attachements!.count > 1) {
            imageView2 = addImageViewWithIndex(1)
            addConstraintsToImageView2(imageView2!, imageView1: imageView1)
            addButtonToView(imageView2!, index: 1)
            
            if (self.object.attachements!.count > 2) {
                imageView3 = addImageViewWithIndex(2)
                addConstraintsToImageView3(imageView3!, imageView2: imageView2!)
                if (object.attachements!.count > 3) {
                    addPlusLabelToView(imageView3!)
                }
                addButtonToView(imageView3!, index: 2)
            }
        }
    }
    
    func removePrevViews() {
        if (imageView1 != nil) {
            imageView1.removeConstraints(imageView1.constraints())
            imageView1.removeFromSuperview()
            imageView1 = nil
        }
        if (imageView2 != nil) {
            imageView2!.removeConstraints(imageView2!.constraints())
            imageView2!.removeFromSuperview()
            imageView2 = nil
        }
        if (imageView3 != nil) {
            imageView3!.removeConstraints(imageView3!.constraints())
            imageView3!.removeFromSuperview()
            imageView3 = nil
        }
        if (plusLabel != nil) {
            plusLabel!.removeConstraints(plusLabel!.constraints())
            plusLabel!.removeFromSuperview()
            plusLabel = nil
        }
        if (button1 != nil) {
            button1!.removeConstraints(button1!.constraints())
            button1!.removeFromSuperview()
            button1 = nil
        }
        if (button2 != nil) {
            button2!.removeConstraints(button2!.constraints())
            button2!.removeFromSuperview()
            button2 = nil
        }
        if (button3 != nil) {
            button3!.removeConstraints(button3!.constraints())
            button3!.removeFromSuperview()
            button3 = nil
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
                make.width.equalTo()(100)
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
                make.width.equalTo()(100)
            }
        }
    }
    
    func addConstraintsToImageView3(imageView: UIImageView, imageView2: UIImageView) {
        imageView.mas_makeConstraints{ make in
            make.height.equalTo()(imageView.mas_width)
            make.left.equalTo()(imageView2.mas_right).offset()(8)
            make.top.equalTo()(imageView2.mas_top)
            make.width.equalTo()(75)
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
        
        plusLabel = label
    }
    
    func addButtonToView(view: UIView, index: Int) {
        var button = UIButton()
        self.borderedView.addSubview(button)
        button.mas_makeConstraints{ make in
            make.edges.equalTo()(view)
        }
        button.tag = index
        button.addTarget(self, action: "openAttachment:", forControlEvents: .TouchUpInside)
        
        switch index {
        case 0:
            button1 = button
        case 1:
            button2 = button
        case 2:
            button3 = button
        default:
            break;
        }
    }
    
    func openAttachment(sender: UIButton) {
        var index: Int = sender.tag
        
        var attachements = object.attachements!
        photos = [MWPhoto]()
        for attach in attachements {
            photos.append(MWPhoto(URL: attach))
        }
        
        var browser = MWPhotoBrowser(delegate: self)
        browser.displayActionButton = true
        browser.displayNavArrows = true
        browser.displaySelectionButtons = false
        browser.zoomPhotosToFill = false
        browser.alwaysShowControls = false
        browser.enableGrid = true
        browser.startOnGrid = false
        browser.setCurrentPhotoIndex(UInt(index))
        
        delegate.navigationController?.pushViewController(browser, animated: true)
    }
}