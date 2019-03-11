//
//  DefaultsManager.swift
//  FlickrViewer
//
//  Created by William Grand on 3/11/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import Foundation

protocol DefaultsManager {
    func set(_ value: Any?, forKey defaultName: String)
    func value(forKey key: String) -> Any?
}

extension UserDefaults: DefaultsManager {}
