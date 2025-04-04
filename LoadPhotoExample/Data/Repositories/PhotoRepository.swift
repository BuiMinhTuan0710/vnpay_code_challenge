//
//  PhotoRepository.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation

protocol PhotoRepository {
    func loadPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], PhotoError>) -> Void)
}

class DefaultPhotoRepository: PhotoRepository {
    private let networkService: DefaultNetworkService
    private let appConfiguration: AppConfiguration

    init(networkService: DefaultNetworkService, appConfiguration: AppConfiguration) {
        self.networkService = networkService
        self.appConfiguration = appConfiguration
    }

    func loadPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], PhotoError>) -> Void) {
        let endpoint = "/list?page=\(page)&limit=\(limit)"
        let urlString = appConfiguration.apiBaseURL + endpoint

        guard let url = URL(string: urlString) else {
            completion(.failure(PhotoError.invalidURL))
            return
        }

        networkService.loadData(from: url) { result in
            switch result {
            case .success(let data):
                do {
                    let photos = try JSONDecoder().decode([Photo].self, from: data)
                    completion(.success(photos))
                } catch {
                    completion(.failure(PhotoError.dataParsingError(error)))
                }
            case .failure(let error):
                completion(.failure(PhotoError.networkError(error)))
            }
        }
    }
}
