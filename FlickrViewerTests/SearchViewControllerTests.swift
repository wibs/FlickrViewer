//
//  FlickrViewerTests.swift
//  FlickrViewerTests
//
//  Created by William Grand on 3/8/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import XCTest
@testable import FlickrViewer


class MockSearcher: Searchable {
    
    var searchExpectation: XCTestExpectation?
    var shouldSucceed: Bool = true
    
    func search(with keyword: String, page: Int?, completion: @escaping (Result<Photos, SearchError>) -> Void) {
        
        let photos = Photos(
            page: 1,
            pages: 3,
            perPage: 25,
            _total: "3",
            photo:
                [Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "Test Title1", ispublic: 0, isfriend: 0, isfamily: 0),
                 Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "", ispublic: 0, isfriend: 0, isfamily: 0),
                 Photo(id: "id", owner: "owner", secret: "secret", server: "server", farm: 1, title: "Test Title3", ispublic: 0, isfriend: 0, isfamily: 0)
                ]
        )
        
        guard shouldSucceed else {
            completion(.failure(.responseStatusError(status: 400, message: "Test Failure")))
            searchExpectation?.fulfill()
            searchExpectation = nil
            return
        }
        
        completion(.success(photos))
        searchExpectation?.fulfill()
        searchExpectation = nil
    }
}

class MockHistoryStore: HistoryStorable {
    
    var getSearchHistoryExpectation: XCTestExpectation?
    
    func getSearchHistory(filteredOn filter: String?) -> [SearchTerm] {
        getSearchHistoryExpectation?.fulfill()
        return ["Test1", "Test2", "Test3"]
    }
    
    func save(searchTerm: SearchTerm) -> [SearchTerm] {
        return ["Test"]
    }
}

class MockNavigationController: UINavigationController {
    var pushedViewController: UIViewController?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: true)
    }
}

class SearchViewControllerTests: XCTestCase {

    var vc: SearchViewController!
    var window: UIWindow!
    
    override func setUp() {
        vc = SearchViewController(historyStore: MockHistoryStore(), searcher: MockSearcher())
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        _ = vc.view
        vc.viewDidLoad()
    }

    func testViewDidLoad() {
        XCTAssertFalse(vc.collectionView.isHidden)
        XCTAssertTrue(vc.suggestionsView.isHidden)
        XCTAssertFalse(vc.searchController.searchBar.isHidden)
        XCTAssertEqual(vc.collectionView.numberOfItems(inSection: 0), 0)
    }
}

// MARK: - Search Results Updater Tests

extension SearchViewControllerTests {
    
    func testUpdateSearchResults() {
        setGetSearchHistoryExpectation(expectation(description: "Get Search History should be called"))
        vc.updateSearchResults(for: vc.searchController)
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// MARK: - Table View Data Source Tests

extension SearchViewControllerTests {
    
    func testNumberOfRowsInSection() {
        vc.updateSearchResults(for: vc.searchController)
        XCTAssertEqual(
            vc.tableView(vc.suggestionsView.tableView, numberOfRowsInSection: 0),
            3
        )
    }
    
    func testCellForRow() {
        vc.updateSearchResults(for: vc.searchController)
        guard let cell = vc.tableView(vc.suggestionsView.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? SuggestionCell else {
            XCTFail("Cell is not a SuggestionCell")
            return
        }
        
        XCTAssertEqual(cell.label.attributedText?.string, "Test1")
    }
}

// MARK: - Table View Delegate Tests

extension SearchViewControllerTests {
    
    func testDidSelectRow() {
        vc.updateSearchResults(for: vc.searchController)

        setSearchExpectation(expectation(description: "Searchable search function should have been called"))
        
        vc.tableView(vc.suggestionsView.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(vc.searchController.searchBar.text, "Test1")
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// MARK: - Collection View Data Source Tests

extension SearchViewControllerTests {
    
    func testCellForItem() {
        vc.searchController.searchBar.text = "test"
        
        setSearchExpectation(expectation(description: "Search should fire off if we have a search term entered"))
        vc.searchBarSearchButtonClicked(vc.searchController.searchBar)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        guard let cell = vc.collectionView(vc.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as? PhotoCell else {
            XCTFail("Cell is not of expected type PhotoCell!")
            return
        }
        
        XCTAssertEqual(cell.label.text, "Test Title1")
        XCTAssertFalse(cell.titleContainer.isHidden)
    }
    
    func testCellForItemNoTitle() {
        vc.searchController.searchBar.text = "test"
        
        setSearchExpectation(expectation(description: "Search should fire off if we have a search term entered"))
        vc.searchBarSearchButtonClicked(vc.searchController.searchBar)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        guard let cell = vc.collectionView(vc.collectionView, cellForItemAt: IndexPath(item: 1, section: 0)) as? PhotoCell else {
            XCTFail("Cell is not of expected type PhotoCell!")
            return
        }
        
        XCTAssertEqual(cell.label.text, "")
        XCTAssertTrue(cell.titleContainer.isHidden)
    }
}

// MARK: - Collection View Delegate Tests

extension SearchViewControllerTests {
    
    func testDidSelectItem() {
        window.rootViewController = nil
        let navController = MockNavigationController()
        navController.show(vc, sender: nil)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        _ = vc.view
        vc.viewDidLoad()
        
        vc.searchController.searchBar.text = "test"
        
        setSearchExpectation(expectation(description: "Search should fire off if we have a search term entered"))
        vc.searchBarSearchButtonClicked(vc.searchController.searchBar)
        
        waitForExpectations(timeout: 1, handler: nil)

        vc.collectionView(vc.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        
        XCTAssertTrue(navController.pushedViewController is PhotoViewController)
    }
}

// MARK: - Search Bar Delegate Tests

extension SearchViewControllerTests {
    
    func testSearchButtonClickedWithTerm() {
        vc.searchController.searchBar.text = "test"
        
        setSearchExpectation(expectation(description: "Search should fire off if we have a search term entered"))
        vc.searchBarSearchButtonClicked(vc.searchController.searchBar)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSearchButtonClickedWithoutTerm() {
        vc.searchController.searchBar.text = ""
        
        let noSearch = expectation(description: "Search should fire off if we have a search term entered")
        noSearch.isInverted = true
        
        setSearchExpectation(noSearch)
        vc.searchBarSearchButtonClicked(vc.searchController.searchBar)
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testSearchButtonClickedWhitespace() {
        vc.searchController.searchBar.text = "   "
        
        let noSearch = expectation(description: "Search should not fire off with only whitespace")
        noSearch.isInverted = true
        
        setSearchExpectation(noSearch)
        vc.searchBarSearchButtonClicked(vc.searchController.searchBar)
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testSearchBarTextDidBeginEditing() {
        vc.searchBarTextDidBeginEditing(vc.searchController.searchBar)
        XCTAssertFalse(vc.suggestionsView.isHidden)
    }
    
    func testSearchBarTextDidEndEditing() {
        vc.searchBarTextDidBeginEditing(vc.searchController.searchBar)
        XCTAssertFalse(vc.suggestionsView.isHidden)
        vc.searchBarTextDidEndEditing(vc.searchController.searchBar)
        XCTAssertTrue(vc.suggestionsView.isHidden)
    }
}

// MARK: - Utility Functions Tests

extension SearchViewControllerTests {
    
    func testDisplayRetryAlert() {
        guard let searcher = vc.searcher as? MockSearcher else {
            XCTFail("Searcher was not of expected type")
            return
        }
        
        searcher.shouldSucceed = false
        
        vc.searchController.searchBar.text = "test"
        
        setSearchExpectation(expectation(description: "Search should fire off if we have a search term entered"))
        vc.searchBarSearchButtonClicked(vc.searchController.searchBar)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        guard let presentedViewController = vc.presentedViewController as? UIAlertController else {
            XCTFail("Not presenting a UIAlertController!")
            return
        }
        
        XCTAssertEqual(presentedViewController.actions.count, 2)
        XCTAssertTrue(presentedViewController.actions.contains { $0.title == "Retry" })
        XCTAssertTrue(presentedViewController.actions.contains { $0.title == "Cancel" })
    }
}

// MARK: - Helpers

extension SearchViewControllerTests {
    func setSearchExpectation(_ expectation: XCTestExpectation) {
        
        guard let searcher = vc.searcher as? MockSearcher else {
            return
        }
        
        searcher.searchExpectation = expectation
    }
    
    func setGetSearchHistoryExpectation(_ expectation: XCTestExpectation) {
        
        guard let historyStore = vc.historyStore as? MockHistoryStore else {
            return
        }
        
        historyStore.getSearchHistoryExpectation = expectation
    }
}
