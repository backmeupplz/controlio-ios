//
//  DeepLink.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 07/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum DeepLinkType: Int {
    case telegram = 1
    case skype
    case messenger
    
    var scheme: String {
        switch self {
        case .telegram:
            return "tg://"
        case .skype:
            return "skype:"
        case .messenger:
            return "fb-messenger://"
        }
    }
    
    var name: String {
        switch self {
        case .telegram:
            return "Telegram"
        case .skype:
            return "Skype"
        case .messenger:
            return "Messenger"
        }
    }
    
    var itunesLink: String {
        switch self {
        case .telegram:
            return "itms://itunes.apple.com/ca/app/telegram-messenger/id686449807"
        case .skype:
            return "itms://itunes.apple.com/ca/app/skype-for-iphone/id304878510"
        case .messenger:
            return "itms://itunes.apple.com/us/app/facebook-messenger/id454638411"
        }
    }
    
    var supportLink: String {
        switch self {
        case .telegram:
            return "tg://resolve?domain=borodutch"
        case .skype:
            return "skype://backmeupplz...?chat"
        case .messenger:
            return "http://m.me/borodutchking"
        }
    }
}

class DeepLink: NSObject {
    
    // MARK: - Class Functions -
    
    class func schemeAvailable(_ type: DeepLinkType) -> Bool {
        return schemeAvailable(type.scheme)
    }
    
    class func openItunes(_ type: DeepLinkType) {
        openLink(type.itunesLink)
    }
    
    class func openSupportLink(_ type: DeepLinkType) {
        openLink(type.supportLink)
    }
    
    // MARK: - Private Class Functions
    
    fileprivate class func schemeAvailable(_ scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    fileprivate class func openLink(_ link: String) {
        UIApplication.shared.openURL(URL(string: link)!)
    }
}
