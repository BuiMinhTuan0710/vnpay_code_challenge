//
//  MockModel.swift
//  LoadPhotoExampleTests
//
//  Created by Bui Tuan on 3/4/25.
//

import Foundation
@testable import LoadPhotoExample

class MockURLProtocol: URLProtocol {
    static var testData: Data?
    static var testError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.testError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else if let data = MockURLProtocol.testData {
            self.client?.urlProtocol(self, didLoad: data)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

class MockLoadPhotoUseCase: LoadPhotoUseCase {
    var shouldReturnError = false
    var mockPhotos: [Photo] = []
    
    func execute(page: Int, limit: Int, completion: @escaping (Result<[LoadPhotoExample.Photo], LoadPhotoExample.PhotoError>) -> Void) {
        if shouldReturnError {
            completion(.failure(.unknownError))
        } else {
            completion(.success(mockPhotos))
        }
    }
}
