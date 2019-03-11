//
//  SearcherTests.swift
//  FlickrViewerTests
//
//  Created by William Grand on 3/11/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import XCTest
@testable import FlickrViewer

class SearcherTests: XCTestCase {
    
    func loadSampleResponse(filename: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: filename, ofType: "")!
        guard let data = NSData(contentsOfFile: path) as Data? else {
            return nil
        }
        
        return data
    }
    
    func testParseResponse() {
        
        let successExpectation = expectation(description: "Finished parsing data")
        
        guard let data = loadSampleResponse(filename: "searchResponse") else {
            XCTFail("Failed to load json data")
            return
        }
        
        let searcher = Searcher()
        searcher.decodeSearchResult(from: data) { result in
            switch result {
            case .success(let photos):
                
                XCTAssertEqual(photos.page, 1)
                XCTAssertEqual(photos.pages, 21082)
                XCTAssertEqual(photos.perPage, 25)
                XCTAssertEqual(photos.total, 527040)
                XCTAssertEqual(
                    photos.photo.first,
                    Photo(
                        id: "32407658507",
                        owner: "38626801@N04",
                        secret: "73ac8d47d5",
                        server: "7815",
                        farm: 8,
                        title: "20190308_181108",
                        ispublic: 1,
                        isfriend: 0,
                        isfamily: 0
                    )
                )
                
                successExpectation.fulfill()
            default:
                print("whoops")
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFailParseResponse() {
        let failureExpectation = expectation(description: "Expected to fail parsing")
        
        guard let data = loadSampleResponse(filename: "badSearchResponse") else {
            XCTFail("Failed to load json data")
            return
        }
        
        let searcher = Searcher()
        searcher.decodeSearchResult(from: data) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                switch error {
                case .decodingError(_,_):
                    failureExpectation.fulfill()
                default:
                    break
                }
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSearchSuccess() {
        
        let mockSession = MockURLSession()
        mockSession.data = loadSampleResponse(filename: "searchResponse")
        mockSession.response = HTTPURLResponse(url: URL(string: "test")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let searcher = Searcher(session: mockSession)
        
        let successfulSearch = expectation(description: "Search executed successfully")
        
        searcher.search(with: "some term", page: 1) { result in
            switch result {
            case .success(let photos):
                
                XCTAssertEqual(photos.page, 1)
                XCTAssertEqual(photos.pages, 21082)
                XCTAssertEqual(photos.perPage, 25)
                XCTAssertEqual(photos.total, 527040)
                XCTAssertEqual(
                    photos.photo.first,
                    Photo(
                        id: "32407658507",
                        owner: "38626801@N04",
                        secret: "73ac8d47d5",
                        server: "7815",
                        farm: 8,
                        title: "20190308_181108",
                        ispublic: 1,
                        isfriend: 0,
                        isfamily: 0
                    )
                )
                successfulSearch.fulfill()
            default:
                print("whoops")
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSearchFailure() {
        
        let mockSession = MockURLSession()
        mockSession.data = loadSampleResponse(filename: "searchResponse")
        mockSession.response = HTTPURLResponse(url: URL(string: "test")!, statusCode: 400, httpVersion: nil, headerFields: nil)
        
        let searcher = Searcher(session: mockSession)
        
        let failedSearch = expectation(description: "Search executed successfully")
        
        searcher.search(with: "some term", page: 1) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                switch error {
                case .responseStatusError(_,_):
                    failedSearch.fulfill()
                default:
                    break
                }
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

class MockDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

class MockURLSession: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    var data: Data?
    var error: Error?
    var response: HTTPURLResponse?
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        let response = self.response
        return MockDataTask {
            completionHandler(data, response, error)
        }
    }
}
