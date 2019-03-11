//
//  PhotosModelTests.swift
//  FlickrViewerTests
//
//  Created by William Grand on 3/11/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import XCTest
@testable import FlickrViewer

class PhotosModelTests: XCTestCase {
    
    func testInitializer() {
        let photo = Photo(
            id: "id",
            owner:"owner",
            secret: "secret",
            server: "server",
            farm: 8,
            title: "Title",
            ispublic: 0,
            isfriend: 0,
            isfamily: 0
        )
        let photos = Photos(
            page: 1,
            pages: 1,
            perPage: 25,
            _total: "123",
            photo: [
                photo
            ]
        )
        
        XCTAssertEqual(photos.page, 1)
        XCTAssertEqual(photos.pages, 1)
        XCTAssertEqual(photos.perPage, 25)
        XCTAssertEqual(photos.total, 123)
        
        guard let initializedPhoto = photos.photo.first else {
            XCTFail("No photos added to object")
            return
        }
        
        XCTAssertEqual(initializedPhoto, photo)
    }
}
