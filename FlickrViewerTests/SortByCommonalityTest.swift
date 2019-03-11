//
//  SortByCommonalityTest.swift
//  FlickrViewerTests
//
//  Created by William Grand on 3/11/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import XCTest
@testable import FlickrViewer

class SortByCommonalityTests: XCTestCase {
    
    func testSort() {
        let array = ["barfoo", "foobarbar", "barbarfoo", "bar", "foo", "foobar"]
        let key = "foo"
        
        let expectedArray = ["foo", "foobar", "foobarbar", "barfoo", "barbarfoo", "bar"]
        
        XCTAssertEqual(array.sortByCommonality(with: key), expectedArray)
    }
}

