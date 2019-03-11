//
//  SuggestionCell.swift
//  FlickrViewer
//
//  Created by William Grand on 3/9/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import UIKit

class SuggestionCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    lazy var label: UILabel = {
        let label = UILabel()
        contentView.addSubview(label)
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Methods

extension SuggestionCell {
    func configure(searchTerm: SearchTerm, highlightedText: String?) {
        let attrs: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.gray]
        let attrString = NSMutableAttributedString(string: searchTerm, attributes: attrs)
        
        if let highlightedText = highlightedText?.lowercased() {
            let range = (searchTerm.lowercased() as NSString).range(of: highlightedText)
            attrString.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.black], range: range)
        }
        
        label.attributedText = attrString
    }
}
