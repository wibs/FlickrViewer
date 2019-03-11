//
//  Photo.swift
//  FlickrViewer
//
//  Created by William Grand on 3/8/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import Foundation

struct Photo: Decodable, Equatable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
    var photoUrl: URL? {
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_h.jpg"
        return URL(string: urlString)
    }
    
    var thumbnailUrl: URL? {
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
        return URL(string: urlString)
    }
}
