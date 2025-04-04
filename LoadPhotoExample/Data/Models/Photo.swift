//
//  Photo.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation

struct Photo: Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadURL: String

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url, downloadURL = "download_url"
    }

    var urlObject: URL? {
        return URL(string: url)
    }

    var downloadURLObject: URL? {
        return URL(string: downloadURL)
    }
}
