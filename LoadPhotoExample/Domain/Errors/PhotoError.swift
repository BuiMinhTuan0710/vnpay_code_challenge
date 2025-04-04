//
//  PhotoError.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation

enum PhotoError: Error {
    case invalidJSON
    case networkError(Error)
    case dataParsingError(Error)
    case invalidURL
    case unknownError

    var localizedDescription: String {
        switch self {
        case .invalidJSON:
            return "Dữ liệu JSON không hợp lệ."
        case .networkError(let error):
            return "Lỗi mạng: \(error.localizedDescription)"
        case .dataParsingError(let error):
            return "Lỗi phân tích dữ liệu ảnh: \(error.localizedDescription)"
        case .invalidURL:
            return "Dữ liệu url không hợp lệ."
        case .unknownError:
            return "Lỗi không xác định."
        }
    }
}
