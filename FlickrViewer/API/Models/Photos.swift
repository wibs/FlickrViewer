//
//  Photos.swift
//  FlickrViewer
//
//  Created by William Grand on 3/8/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import Foundation

struct PhotosResponse: Decodable {
    let photos: Photos
    let stat: String
}

struct Photos: Decodable {
    let page: Int
    let pages: Int
    let perPage: Int
    let _total: String
    var total: Int {
        return Int(_total) ?? -1
    }
    let photo: [Photo]

    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case photo
        case _total = "total"
        case perPage = "perpage"
    }
}
