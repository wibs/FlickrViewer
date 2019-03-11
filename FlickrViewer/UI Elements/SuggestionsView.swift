//
//  SuggestionsView.swift
//  FlickrViewer
//
//  Created by William Grand on 3/10/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import UIKit

class SuggestionsView: UIView {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SuggestionCell.self, forCellReuseIdentifier: "SuggestionCell")
        self.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        return tableView
    }()
}
