//
//  ArrayExtensions.swift
//  FlickrViewer
//
//  Created by William Grand on 3/11/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import Foundation

extension Array where Element == String {
    
    func sortByCommonality(with key: String) -> [String] {
        return sorted {
            switch ($0.lowercased(), $1.lowercased()) {
            case (let val1, let val2) where val1 == key && val2 != key:
                return true
            case (let val1, let val2) where val1.hasPrefix(key) && !val2.hasPrefix(key):
                return true
            case (let val1, let val2) where val1.hasPrefix(key) && val2.hasPrefix(key) && val1.count < val2.count:
                return true
            case (let val1, let val2) where val1.contains(key) && !val2.contains(key):
                return true
            case (let val1, let val2) where val1.contains(key) && val2.contains(key) && val1.count < val2.count:
                return true
            default:
                return false
            }
        }
    }
}
