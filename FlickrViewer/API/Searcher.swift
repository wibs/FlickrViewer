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
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.dataTaskError(error: error, message: "Failed to execute data task: \(error)")))
                }
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.responseError(message: "Failed to retrieve data from response")))
                }
                return
            }
            
            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.responseStatusError(status: response.statusCode,
                                                             message: "Failed with status: \(response.statusCode)")))
                }
                return
            }

            self.decodeSearchResult(from: data, completion: completion)
        }
        
        dataTask?.resume()
    }
    
    func decodeSearchResult(from data: Data, completion: @escaping (Result<Photos, SearchError>) -> Void) {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(PhotosResponse.self, from: data)
            
            DispatchQueue.main.async {
                completion(.success(result.photos))
            }
        } catch let decodingError {
            NSLog("Error decoding search results: \(decodingError)")
            DispatchQueue.main.async {
                completion(.failure(.decodingError(error: decodingError, message: "Failed to decode: \(decodingError)")))
            }
        }
    }
}


enum Result<Value, Error> {
    case success(Value)
    case failure(Error)
}

