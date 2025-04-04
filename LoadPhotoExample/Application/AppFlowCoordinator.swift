//
//  AppFlowCoordinator.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 2/4/25.
//

import Foundation
import UIKit

final class AppFlowCoordinator {
    private let navigationController: UINavigationController
    private let appDIContainer: AppDIContainer

    init(navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    func start() {
        let photoViewController = appDIContainer.makePhotoViewController()
        navigationController.pushViewController(photoViewController, animated: false)
    }
}
