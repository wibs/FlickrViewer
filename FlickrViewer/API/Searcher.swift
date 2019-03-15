//
//  Searchable.swift
//  FlickrViewer
//
//  Created by William Grand on 3/8/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import Foundation

protocol Searchable {
    func search(with keyword: String, page: Int?, completion: @escaping (Result<Photos, SearchError>) -> Void)
}

enum SearchError: Error {
    case responseError(message: String)
    case responseStatusError(status: Int, message: String)
    case decodingError(error: Error, message: String)
    case dataTaskError(error: Error, message: String)
}

class Searcher: Searchable {
    
    var dataTask: URLSessionDataTask?
    let session: URLSession
    
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func search(with keyword: String, page: Int?, completion: @escaping (Result<Photos, SearchError>) -> Void) {
        dataTask?.cancel()

        let request = FlickrSearchRequest(text: keyword, page: page ?? 1)
        guard let url = request.url else {
            return
        }
        
        dataTask = session.dataTask(with: url) { data, response, error in
            
            var result: Result<Photos, SearchError> = Result.failure(SearchError.responseError(message: ""))
            
            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error = error {
                result = .failure(.dataTaskError(error: error, message: "Failed to execute data task: \(error)"))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                result = .failure(.responseError(message: "Failed to retrieve data from response"))
                return
            }
            
            guard response.statusCode == 200 else {
                result = .failure(.responseStatusError(status: response.statusCode,
                                                             message: "Failed with status: \(response.statusCode)"))
                return
            }

            result = self.decodeSearchResult(from: data)
        }
        
        dataTask?.resume()
    }
    
    func decodeSearchResult(from data: Data) -> Result<Photos, SearchError> {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(PhotosResponse.self, from: data)
            
            return .success(result.photos)
        } catch let decodingError {
            NSLog("Error decoding search results: \(decodingError)")
            return .failure(.decodingError(error: decodingError, message: "Failed to decode: \(decodingError)"))
        }
    }
}


enum Result<Value, Error> {
    case success(Value)
    case failure(Error)
}

