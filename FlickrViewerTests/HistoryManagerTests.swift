//
//  HistoryManagerTests.swift
//  FlickrViewerTests
//
//  Created by William Grand on 3/11/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import XCTest
@testable import FlickrViewer

class MockDefaultsManager: DefaultsManager {
    
    private var defaults: [String: Any] = [:]
    
    func set(_ value: Any?, forKey defaultName: String) {
        defaults[defaultName] = value
    }
    
    func value(forKey key: String) -> Any? {
        return defaults[key]
    }
}

class HistoryManagerTests: XCTestCase {

    func testSaveItem() {
        let historyManager = HistoryStore(defaultsManager: MockDefaultsManager())
        _ = historyManager.save(searchTerm: "Test1")
        
        XCTAssertEqual(historyManager.getSearchHistory(filteredOn: nil).first, "Test1")
    }
    
    func testSaveDuplicateItem() {
        let historyManager = HistoryStore(defaultsManager: MockDefaultsManager())
        _ = historyManager.save(searchTerm: "Test1")
        _ = historyManager.save(searchTerm: "Test1")
        
        XCTAssertEqual(historyManager.getSearchHistory(filteredOn: nil).count, 1)
        XCTAssertEqual(historyManager.getSearchHistory(filteredOn: nil).first, "Test1")
    }
}
