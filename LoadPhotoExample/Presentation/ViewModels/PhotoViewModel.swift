//
//  PhotoViewModel.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation
import UIKit

class PhotoViewModel {
    private let loadPhotoUseCase: LoadPhotoUseCase
    private var photos: [Photo] = []
    private var filterPhotos: [Photo] = []
    private var page: Int = 1
    private let limit: Int = 100
    private(set) var hasMoreData = true
    private var searchText: String = ""
    private var searchWorkItem: DispatchWorkItem?
    private var searchQueue = DispatchQueue(label: "search.queue", qos: .userInitiated)
    private var imageLoadOperations: [IndexPath: ImageLoadOperation] = [:]
    private let downloadQueue = OperationQueue()
    
    var dataSource: [Photo] {
        return isFilter ? filterPhotos : photos
    }
    
    var errorMessage: String?
    var isLoading: Bool = false
    var isFilter: Bool = false
    var photosLoaded: (() -> Void)?
    var errorOccurred: (() -> Void)?
    var loadingStateChanged: (() -> Void)?
    
    init(loadPhotoUseCase: LoadPhotoUseCase) {
        self.loadPhotoUseCase = loadPhotoUseCase
    }
    
    func loadPhotos() {
        isLoading = true
        loadingStateChanged?()
        
        loadPhotoUseCase.execute(page: page, limit: limit) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.loadingStateChanged?()
                
                switch result {
                case .success(let photos):
                    self.photos.append(contentsOf: photos)
                    self.filterPhotos = self.photos.filter({$0.author.contains(self.searchText) || $0.id.contains(self.searchText)})
                    self.photosLoaded?()
                    self.page += 1
                    if photos.count < self.limit {
                        self.hasMoreData = false
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.errorOccurred?()
                }
            }
        }
    }
    
    func filterPhotos( searchText: String) {
        self.searchText = searchText
        self.isFilter = true
        self.searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.filterPhotos = self.photos.filter({$0.author.contains(self.searchText) || $0.id.contains(self.searchText)})
            self.photosLoaded?()
        }
        
        self.searchWorkItem = workItem
        searchQueue.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }
    
    func resetData() {
        photos = []
        page = 1
        hasMoreData = true
        isFilter = false
    }
    
    func loadImage(photo: Photo, indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: photo.downloadURL) else {
            completion(nil)
            return
        }
        
        let muti = CGFloat(photo.width) / CGFloat(photo.height)
        let width = UIScreen.main.bounds.width
        let height = width / muti
        let targetSize = CGSize(width: width, height: height)
        
        let photoRecord = PhotoRecord(url: url)
        if let cachedImage = ImageCache.shared.getImage(forKey: photoRecord.url.absoluteString) {
            completion(cachedImage)
            return
        }
        
        if imageLoadOperations[indexPath] == nil {
            let operation = ImageLoadOperation(photoRecord: photoRecord, indexPath: indexPath, targetSize: targetSize) { updatedRecord, updatedIndexPath in
                DispatchQueue.main.async {
                    if updatedRecord.state == .downloaded, let image = updatedRecord.image {
                        completion(image.resizeImage(targetSize: targetSize))
                    } else {
                        completion(nil)
                    }
                    self.imageLoadOperations.removeValue(forKey: updatedIndexPath)
                }
            }
            imageLoadOperations[indexPath] = operation
            downloadQueue.addOperation(operation)
        }
    }
    
    func clearCache() {
        imageLoadOperations.values.forEach { $0.cancel() }
        imageLoadOperations.removeAll()
        ImageCache.shared.clearCache()
    }
}
