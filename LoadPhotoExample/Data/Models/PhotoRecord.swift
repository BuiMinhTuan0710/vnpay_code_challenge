//
//  PhotoRecord.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation
import UIKit

enum PhotoRecordState {
    case new
    case downloaded
    case failed
}

struct PhotoRecord {
    let url: URL
    var image: UIImage?
    var state: PhotoRecordState = .new
    
    init(url: URL) {
        self.url = url
    }
}
