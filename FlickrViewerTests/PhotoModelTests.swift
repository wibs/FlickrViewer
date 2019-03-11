//
//  PhotoModelTests.swift
//  FlickrViewerTests
//
//  Created by William Grand on 3/11/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import XCTest
@testable import FlickrViewer

class PhotoModelTests: XCTestCase {
    
    func testInitializer() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 8, title: "Test", ispublic: 0, isfriend: 0, isfamily: 0)
        XCTAssertEqual(photo.id, "id")
        XCTAssertEqual(photo.owner, "owner")
        XCTAssertEqual(photo.secret, "secret")
        XCTAssertEqual(photo.server, "server")
        XCTAssertEqual(photo.farm, 8)
        XCTAssertEqual(photo.title, "Test")
        XCTAssertEqual(photo.ispublic, 0)
        XCTAssertEqual(photo.isfriend, 0)
        XCTAssertEqual(photo.isfamily, 0)
    }
    
    func testUrl() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 8, title: "Test", ispublic: 0, isfriend: 0, isfamily: 0)
        let url = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_h.jpg")
        XCTAssertEqual(photo.photoUrl, url)
    }
    
    func testThumbnailUrl() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 8, title: "Test", ispublic: 0, isfriend: 0, isfamily: 0)
        let url = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg")
        XCTAssertEqual(photo.thumbnailUrl, url)
    }
}
