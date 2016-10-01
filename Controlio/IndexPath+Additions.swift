//
//  IndexPath+Additions.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 07/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension IndexPath {
    static func range(start: Int = 0, length: Int = 20, section: Int = 0) -> [IndexPath] {
        guard length >= 0 else { return [] }
        var result = [IndexPath]()
        for index in start ..< start+length {
            result.append(IndexPath(row: index, section: section))
        }
        return result
    }
}
