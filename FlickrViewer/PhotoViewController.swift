//
//  PhotoViewController.swift
//  FlickrViewer
//
//  Created by William Grand on 3/8/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewController: UIViewController {
    
    // MARK: - Properties
    
    let photo: Photo
    
    private var isImageFocused: Bool = false
    
    private var descriptionAnchor: NSLayoutConstraint?
    
    // MARK: - UI Elements
    
    lazy var titleContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        container.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        
        view.addSubview(container)
        
        container.autoPinEdge(toSuperviewEdge: .left)
        container.autoPinEdge(toSuperviewEdge: .right)
        descriptionAnchor = container.autoPinEdge(toSuperviewSafeArea: .bottom)
        
        container.isHidden = photo.title.trimmingCharacters(in: .whitespaces).count == 0
        return container
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 4
        label.textColor = .white
        label.contentMode = .topLeft
        label.text = photo.title
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let newImageView = UIImageView()
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        scrollView.addSubview(newImageView)
        return newImageView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea()
        return scrollView
    }()
    
    lazy var waitSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.color = UIColor(white: 1.0, alpha: 0.8)
        view.addSubview(spinner)
        spinner.autoCenterInSuperview()
        return spinner
    }()
    
    // MARK: - Initializers
    
    init(photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle Methods

extension PhotoViewController {
    override func viewDidLoad() {
        self.view.backgroundColor = .black
        _ = scrollView
        _ = titleContainer
        setUpGestureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpImageView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        waitSpinner.stopAnimating()
        imageView.sd_cancelCurrentImageLoad()
    }
    

}

// MARK: - Setup Methods

extension PhotoViewController {
    
    func setUpImageView() {
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        self.scrollView.contentSize = self.imageView.frame.size
        imageView.sd_imageTransition = .fade
        waitSpinner.startAnimating()
        imageView.sd_setImage(with: photo.photoUrl) { _,_,_,_ in
            self.waitSpinner.stopAnimating()
        }
    }
    
    func setUpGestureRecognizers() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(focusImage))
        scrollView.addGestureRecognizer(imageTap)
    }
}

// MARK: - Utility Methods

extension PhotoViewController {
    
    @objc func focusImage() {
        isImageFocused = !isImageFocused
        
        var alpha = CGFloat(1.0)
        descriptionAnchor?.autoRemove()
        
        if isImageFocused {
            alpha = 0
            descriptionAnchor = titleContainer.autoPinEdge(.top, to: .bottom, of: view)
        } else {
            descriptionAnchor = titleContainer.autoPinEdge(toSuperviewSafeArea: .bottom)
        }
        
        navigationController?.setNavigationBarHidden(isImageFocused, animated: true)
        
        UIView.animate(withDuration: 0.2) {
            if !self.isImageFocused {
                self.scrollView.zoomScale = 1.0
            }
            self.titleContainer.alpha = alpha
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UIScrollViewDelegate Methods

extension PhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if !isImageFocused {
            focusImage()
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == 1.0 {
            focusImage()
        }
    }
}
