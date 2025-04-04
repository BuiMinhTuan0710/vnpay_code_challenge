//
//  ImageLoadOperation.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation
import UIKit

class ImageLoadOperation: Operation {
    let photoRecord: PhotoRecord
    let indexPath: IndexPath
    var completion: ((PhotoRecord, IndexPath) -> Void)?
    var targetSize: CGSize
    private var dataTask: URLSessionDataTask?

    init(photoRecord: PhotoRecord, indexPath: IndexPath, targetSize: CGSize, completion: ((PhotoRecord, IndexPath) -> Void)?) {
        self.photoRecord = photoRecord
        self.indexPath = indexPath
        self.targetSize = targetSize
        self.completion = completion
    }

    override func main() {
        guard !isCancelled else { return }

        var mutableRecord = photoRecord
        if let cachedImage = ImageCache.shared.getImage(forKey: photoRecord.url.absoluteString) {
            mutableRecord.image = cachedImage
            mutableRecord.state = .downloaded
            DispatchQueue.main.async {
                self.completion?(mutableRecord, self.indexPath)
            }
            return
        }

        dataTask = URLSession.shared.dataTask(with: mutableRecord.url) { [weak self] data, response, error in
            guard let self = self, !self.isCancelled, let data = data, let image = UIImage(data: data) else {
                mutableRecord.state = .failed
                DispatchQueue.main.async {
                    self?.completion?(mutableRecord, self?.indexPath ?? IndexPath())
                }
                return
            }

            mutableRecord.image = image
            mutableRecord.state = .downloaded
            if let resizeImage = image.resizeImage(targetSize: self.targetSize)?.compressImage(compressionQuality: 0.7),
               let compressedImage = UIImage(data: resizeImage) {
                ImageCache.shared.setImage(compressedImage, forKey: self.photoRecord.url.absoluteString)
            }

            DispatchQueue.main.async {
                self.completion?(mutableRecord, self.indexPath)
            }
        }
        dataTask?.resume()
    }

    override func cancel() {
        super.cancel()
        dataTask?.cancel()
    }
}
