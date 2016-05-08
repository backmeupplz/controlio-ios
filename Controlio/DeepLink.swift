//
//  DeepLink.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 07/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum DeepLinkType: Int {
    case Telegram = 1
    case Skype
    case Messenger
    
    var scheme: String {
        switch self {
        case Telegram:
            return "tg://"
        case Skype:
            return "skype:"
        case Messenger:
            return "fb-messenger://"
        }
    }
    
    var name: String {
        switch self {
        case Telegram:
            return "Telegram"
        case Skype:
            return "Skype"
        case Messenger:
            return "Messenger"
        }
    }
    
    var itunesLink: String {
        switch self {
        case Telegram:
            return "itms://itunes.apple.com/ca/app/telegram-messenger/id686449807"
        case Skype:
            return "itms://itunes.apple.com/ca/app/skype-for-iphone/id304878510"
        case Messenger:
            return "itms://itunes.apple.com/us/app/facebook-messenger/id454638411"
        }
    }
    
    var supportLink: String {
        switch self {
        case Telegram:
            return "tg://resolve?domain=borodutch"
        case Skype:
            return "skype://backmeupplz...?chat"
        case Messenger:
            return "http://m.me/borodutchking"
        }
    }
}

class DeepLink: NSObject {
    
    // MARK: - Class Functions -
    
    class func schemeAvailable(type: DeepLinkType) -> Bool {
        return schemeAvailable(type.scheme)
    }
    
    class func openItunes(type: DeepLinkType) {
        openLink(type.itunesLink)
    }
    
    class func openSupportLink(type: DeepLinkType) {
        openLink(type.supportLink)
    }
    
    // MARK: - Private Class Functions
    
    private class func schemeAvailable(scheme: String) -> Bool {
        if let url = NSURL(string: scheme) {
            return UIApplication.sharedApplication().canOpenURL(url)
        }
        return false
    }

    private class func openLink(link: String) {
        UIApplication.sharedApplication().openURL(NSURL(string: link)!)
    }
}
