//
//  AppDIContainer.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation
import UIKit

final class AppDIContainer {
    let appConfiguration = AppConfiguration()

    lazy var networkService: DefaultNetworkService = {
        return DefaultNetworkService(appConfiguration: appConfiguration)
    }()

    lazy var photoRepository: DefaultPhotoRepository = {
        return DefaultPhotoRepository(networkService: networkService, appConfiguration: appConfiguration)
    }()

    lazy var loadPhotoUseCase: DefaultLoadPhotoUseCase = {
        return DefaultLoadPhotoUseCase(photoRepository: photoRepository)
    }()

    func makePhotoViewModel() -> PhotoViewModel {
        return PhotoViewModel(loadPhotoUseCase: loadPhotoUseCase)
    }

    func makePhotoViewController() -> PhotoViewController {
        return PhotoViewController(viewModel: makePhotoViewModel())
    }
}
