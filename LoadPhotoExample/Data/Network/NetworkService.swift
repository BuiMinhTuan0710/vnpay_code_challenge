//
//  NetworkService.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation

protocol NetworkService {
    func loadData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

class DefaultNetworkService: NetworkService {
    private let appConfiguration: AppConfiguration
    
    init(appConfiguration: AppConfiguration) {
        self.appConfiguration = appConfiguration
    }
    
    func loadData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: configuration)
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Data not found", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
