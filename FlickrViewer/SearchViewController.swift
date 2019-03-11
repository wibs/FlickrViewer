//
//  ViewController.swift
//  FlickrViewer
//
//  Created by William Grand on 3/8/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import UIKit
import PureLayout

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    let itemsPerRow = 3
    private var currentSearchTerm: SearchTerm = "" {
        didSet {
            currentSearchTerm = currentSearchTerm.trimmingCharacters(in: .whitespaces)
        }
    }
    private var currentPage = 1 {
        didSet {
            currentPage = min(currentPage, maximumPage)
        }
    }
    private var maximumPage = 1
    
    let historyStore: HistoryStorable
    let searcher: Searchable
    
    private var suggestionsHeightConstraint: NSLayoutConstraint? = nil {
        didSet {
            oldValue?.autoRemove()
        }
    }
    
    private var searchHistory: [SearchTerm] = [] {
        didSet {
            suggestionsView.tableView.reloadData()
        }
    }

    private var photos: [Photo] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var flowLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        return layout
    }
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Flickr"
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    // MARK: - UI Elements
    
    lazy var suggestionsView: SuggestionsView = {
        
        let suggestionsView = SuggestionsView()
        
        suggestionsView.tableView.delegate = self
        suggestionsView.tableView.dataSource = self
        
        view.addSubview(suggestionsView)
        
        suggestionsView.isHidden = true
        suggestionsView.autoPin(toTopLayoutGuideOf: self, withInset: 0)
        suggestionsView.autoPinEdge(.left, to: .left, of: self.view)
        suggestionsView.autoPinEdge(.right, to: .right, of: self.view)
        suggestionsHeightConstraint = suggestionsView.autoSetDimension(.height, toSize: 0)
        
        return suggestionsView
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.view.addSubview(collectionView)
        
        collectionView.autoPinEdge(.top, to: .bottom, of: suggestionsView)
        collectionView.autoPinEdge(toSuperviewSafeArea: .left)
        collectionView.autoPinEdge(toSuperviewSafeArea: .right)
        collectionView.autoPinEdge(toSuperviewEdge: .bottom)
        
        return collectionView
    }()
    

    
    // MARK: - Initializers
    
    init(historyStore: HistoryStorable = HistoryStore(), searcher: Searchable = Searcher()) {
        self.historyStore = historyStore
        self.searcher = searcher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle Methods

extension SearchViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        _ = collectionView
    }
}

// MARK: - UISearchResultsUpdating Methods

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let term = searchController.searchBar.text else {
            return
        }

        searchHistory = historyStore.getSearchHistory(filteredOn: term)
    }
}

// MARK: - UITableViewDataSource Methods

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath) as? SuggestionCell else {
            fatalError()
        }
        
        cell.configure(searchTerm: searchHistory[indexPath.row], highlightedText: searchController.searchBar.text)
        
        return cell
    }
}

// MARK: - UITableViewDelegate Methods

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSearch(with: searchHistory[indexPath.row])
        searchController.searchBar.text = searchHistory[indexPath.row]
        searchController.searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource Methods

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            fatalError()
        }
        
        cell.configure(photo: photos[indexPath.row])
        
        return  cell
    }
}

// MARK: - UICollectionViewDelegate Methods

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchController.searchBar.resignFirstResponder()
        navigationController?.pushViewController(PhotoViewController(photo: photos[indexPath.row]), animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            if currentPage != maximumPage {
                currentPage += 1
                load(page: currentPage, for: currentSearchTerm)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Methods

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0.0
        
        let baseRowWidth = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        let totalItemSpacingWidth = CGFloat(itemsPerRow - 1) * itemSpacing
        let adjustedRowWidth = baseRowWidth - totalItemSpacingWidth
        
        let cellWidth = adjustedRowWidth/CGFloat(itemsPerRow)
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - UISearchBarDelegate Methods

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespaces), searchText.count > 0 else {
            return
        }
        
        performSearch(with: searchText)
    }

    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        toggleSuggestions()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        toggleSuggestions()
    }
}

// MARK: - Utility Methods

extension SearchViewController {
    
    private func performSearch(with searchTerm: SearchTerm, page: Int = 1) {
        _ = historyStore.save(searchTerm: searchTerm)
        currentSearchTerm = searchTerm
        
        searcher.search(with: searchTerm, page: page) { result in
            switch result {
            case .success(let searchResult):
                self.process(searchResult)
            case .failure(let error):
                self.displayRetryAlert()
                NSLog("Error searching: \(error)")
                return
            }
        }
    }
    
    private func displayRetryAlert() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong while searching.. Want to try again?", preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            self.performSearch(with: self.currentSearchTerm)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        [retryAction, cancelAction].forEach {
            alert.addAction($0)
        }
        
        present(alert, animated: true)
    }
    
    private func process(_ photos: Photos) {
        if photos.page > 1 {
            self.photos.append(contentsOf: photos.photo)
        } else {
            self.photos = photos.photo
            self.maximumPage = photos.pages
            self.collectionView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
        }
    }
    
    func load(page: Int, for searchTerm: SearchTerm) {
        guard searchTerm.count > 0 else {
            return
        }
        
        performSearch(with: searchTerm, page: page)
    }
    
    private func toggleSuggestions() {
        guard let suggestionsHeightConstraint = suggestionsHeightConstraint else {
            return
        }
        
        if suggestionsHeightConstraint.constant > CGFloat(0.0) {
            suggestionsHeightConstraint.constant = 0
            suggestionsView.isHidden = true
        }
        else {
            suggestionsHeightConstraint.constant = 200
            suggestionsView.tableView.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
            suggestionsView.isHidden = false
            searchHistory = historyStore.getSearchHistory(filteredOn: nil)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if self.suggestionsView.isHidden == false {
                self.suggestionsView.tableView.flashScrollIndicators()
            }
        })
    }
}


