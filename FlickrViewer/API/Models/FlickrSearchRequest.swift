//
//  FlickrSearchRequest.swift
//  FlickrViewer
//
//  Created by William Grand on 3/10/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import Foundation

struct FlickrSearchRequest {
    let method: String = "flickr.photos.search"
    let format: String = "json"
    let apiKey: String = "1508443e49213ff84d566777dc211f2a"
    let text: String
    let page: Int
    let perPage: Int = 25
}

// MARK: - Request Protocol Implementation

extension FlickrSearchRequest {
    var url: URL? {
        
        guard var components = URLComponents(string: "https://api.flickr.com/services/rest/") else {
            NSLog("Failed to create URL Component")
            return nil
        }
        
        components.queryItems =
            [
                URLQueryItem(name: "method", value: self.method),
                URLQueryItem(name: "format", value: self.format),
                URLQueryItem(name: "api_key", value: self.apiKey),
                URLQueryItem(name: "text", value: self.text),
                URLQueryItem(name: "per_page", value: String(self.perPage)),
                URLQueryItem(name: "page", value: String(self.page)),
                URLQueryItem(name: "nojsoncallback", value: "1"),
                URLQueryItem(name: "safe_search", value: "1")
        ]
        
        guard let url = components.url else {
            NSLog("Failed to create url from url components")
            return nil
        }
        
        return url
    }
}
