//
//  PhotoViewControllerTests.swift
//  FlickrViewerTests
//
//  Created by William Grand on 3/11/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import XCTest
@testable import FlickrViewer

class PhotoViewControllerTests: XCTestCase {
    
    var vc: PhotoViewController!
    var window: UIWindow!
}

// MARK: - Lifecycle Method Tests

extension PhotoViewControllerTests {
    func testViewDidLoadWithPhotoTitle() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "Test Title", ispublic: 0, isfriend: 0, isfamily: 0)
        makeTestableViewController(with: photo)
        XCTAssertFalse(vc.scrollView.isHidden)
        XCTAssertFalse(vc.scrollView.isZooming)
        XCTAssertFalse(vc.titleContainer.isHidden)
        XCTAssertFalse(vc.titleLabel.isHidden)
        XCTAssertEqual(vc.titleLabel.text, photo.title)
        XCTAssertFalse(vc.waitSpinner.isHidden)
        XCTAssertTrue(vc.waitSpinner.isAnimating)
        
        XCTAssertTrue(vc.scrollView.gestureRecognizers?.last is UITapGestureRecognizer)
    }
    
    func testViewDidLoadWithoutPhotoTitle() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "", ispublic: 0, isfriend: 0, isfamily: 0)
        makeTestableViewController(with: photo)
        XCTAssertFalse(vc.scrollView.isHidden)
        XCTAssertFalse(vc.scrollView.isZooming)
        XCTAssertTrue(vc.titleContainer.isHidden)
        XCTAssertFalse(vc.titleLabel.isHidden)
        XCTAssertEqual(vc.titleLabel.text, photo.title)
        XCTAssertFalse(vc.waitSpinner.isHidden)
        XCTAssertTrue(vc.waitSpinner.isAnimating)
    }
    
    func testViewDidLoadWithWhitespacePhotoTitle() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "   ", ispublic: 0, isfriend: 0, isfamily: 0)
        makeTestableViewController(with: photo)
        XCTAssertFalse(vc.scrollView.isHidden)
        XCTAssertFalse(vc.scrollView.isZooming)
        XCTAssertTrue(vc.titleContainer.isHidden)
        XCTAssertFalse(vc.titleLabel.isHidden)
        XCTAssertEqual(vc.titleLabel.text, photo.title)
        XCTAssertFalse(vc.waitSpinner.isHidden)
        XCTAssertTrue(vc.waitSpinner.isAnimating)
    }
    
    func testViewWillDisappear() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "   ", ispublic: 0, isfriend: 0, isfamily: 0)
        makeTestableViewController(with: photo)
        vc.viewWillDisappear(false)
        XCTAssertFalse(vc.waitSpinner.isAnimating)
    }
}

// MARK: Scroll View Delegate Tests

extension PhotoViewControllerTests {
    
    func testViewForZooming() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "   ", ispublic: 0, isfriend: 0, isfamily: 0)
        makeTestableViewController(with: photo)
        XCTAssertEqual(vc.viewForZooming(in: vc.scrollView), vc.imageView)
    }
    
    func testScrollViewWillBeginZooming() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "   ", ispublic: 0, isfriend: 0, isfamily: 0)
        makeTestableViewController(with: photo)
        
        vc.scrollViewWillBeginZooming(vc.scrollView, with: vc.imageView)

        XCTAssertTrue(vc.navigationController?.isNavigationBarHidden ?? false)
    }
    
    func testScrollViewDidEndZoomingAtStartingScale() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "   ", ispublic: 0, isfriend: 0, isfamily: 0)
        makeTestableViewController(with: photo)
        
        vc.scrollViewWillBeginZooming(vc.scrollView, with: vc.imageView)
        vc.scrollViewDidEndZooming(vc.scrollView, with: vc.imageView, atScale: 1.0)
        XCTAssertFalse(vc.navigationController?.isNavigationBarHidden ?? true)
    }
    
    func testScrollViewDidEndZoomingAtLargerScale() {
        let photo = Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "   ", ispublic: 0, isfriend: 0, isfamily: 0)
        makeTestableViewController(with: photo)
        
        vc.scrollViewWillBeginZooming(vc.scrollView, with: vc.imageView)
        vc.scrollViewDidEndZooming(vc.scrollView, with: vc.imageView, atScale: 2.0)
        XCTAssertTrue(vc.navigationController?.isNavigationBarHidden ?? true)
    }
}

// MARK: - Helpers

extension PhotoViewControllerTests {
    
    func makeTestableViewController(with photo: Photo) {
        vc = PhotoViewController(photo: photo)
        window = UIWindow(frame: UIScreen.main.bounds)
        let navController = MockNavigationController()
        navController.show(vc, sender: nil)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        _ = vc.view
        vc.viewDidLayoutSubviews()
    }
}
