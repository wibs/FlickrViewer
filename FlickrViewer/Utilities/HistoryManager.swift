//
//  HistoryManager.swift
//  FlickrViewer
//
//  Created by William Grand on 3/9/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import Foundation

typealias SearchTerm = String

protocol HistoryStorable {
    func save(searchTerm: SearchTerm) -> [SearchTerm]
    func getSearchHistory(filteredOn filter: String?) -> [SearchTerm]
}

struct HistoryStore: HistoryStorable {
    
    let defaultsManager: DefaultsManager
    
    init(defaultsManager: DefaultsManager = UserDefaults.standard) {
        self.defaultsManager = defaultsManager
    }
    
    let historyKey = "searchHistory"
    
    func save(searchTerm: SearchTerm) -> [SearchTerm] {
        var history = getSearchHistory(filteredOn: nil)
        
        if !history.contains(searchTerm) {
            history.insert(searchTerm, at: 0)
            defaultsManager.set(history, forKey: historyKey)
        }
        
        return history
    }
    
    func getSearchHistory(filteredOn filter: String?) -> [SearchTerm] {
        var history = defaultsManager.value(forKey: historyKey) as? [SearchTerm] ?? []
        
        if let filter = filter?.lowercased(), filter.count > 0 {
            history = history.sortByCommonality(with: filter)
        }
        
        return history
    }
}
