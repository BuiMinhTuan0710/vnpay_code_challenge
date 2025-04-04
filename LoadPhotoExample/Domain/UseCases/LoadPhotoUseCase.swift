//
//  LoadPhotoUseCase.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation

protocol LoadPhotoUseCase {
    func execute(page: Int, limit: Int, completion: @escaping (Result<[Photo], PhotoError>) -> Void)
}

class DefaultLoadPhotoUseCase: LoadPhotoUseCase {
    private let photoRepository: PhotoRepository

    init(photoRepository: PhotoRepository) {
        self.photoRepository = photoRepository
    }

    func execute(page: Int, limit: Int, completion: @escaping (Result<[Photo], PhotoError>) -> Void) {
        photoRepository.loadPhotos(page: page, limit: limit) { result in
            switch result {
            case .success(let photos):
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
