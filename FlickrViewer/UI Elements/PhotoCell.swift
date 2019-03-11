//
//  PhotoCell.swift
//  FlickrViewer
//
//  Created by William Grand on 3/8/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoCell: UICollectionViewCell {

    // MARK: - Properties
    
    var photo: Photo? = nil
    
    // MARK: - UI Elements
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.sd_imageTransition = .fade
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewSafeArea()
        return imageView
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        titleContainer.addSubview(label)
        label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        return label
    }()
    
    lazy var titleContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        contentView.addSubview(container)
        container.autoPinEdge(toSuperviewEdge: .left)
        container.autoPinEdge(toSuperviewEdge: .right)
        container.autoPinEdge(toSuperviewEdge: .bottom)
        return container
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 3
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true
        
        _ = imageView
        _ = titleContainer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle Methods

extension PhotoCell {
    
    override func prepareForReuse() {
        imageView.sd_cancelCurrentImageLoad()
    }
}

// MARK: - Setup Methods

extension PhotoCell{
    func configure(photo: Photo) {
        if photo.photoUrl != self.photo?.photoUrl {
            self.photo = photo
            titleContainer.isHidden = photo.title.trimmingCharacters(in: .whitespaces).count == 0
            label.text = photo.title
            imageView.sd_setImage(with: photo.thumbnailUrl, completed: nil)
        }
    }
}
