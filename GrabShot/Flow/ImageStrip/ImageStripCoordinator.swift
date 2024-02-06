//
//  ImageStripCoordinator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI

class ImageStripCoordinator: Coordinator<ImageStripRouter, ImageStripError> {
    @ObservedObject var imageStore: ImageStore
    @ObservedObject var scoreController: ScoreController
    var videModels: [any ObservableObject] = []
    
    init(imageStore: ImageStore, scoreController: ScoreController) {
        self.imageStore = imageStore
        self.scoreController = scoreController
        super.init(route: .sidebar)
    }
    
    override func buildViewModel(_ route: ImageStripRouter) -> (any ObservableObject)? {
        switch route {
        case .sidebar:
            if let viewModel = viewModels.first(where: { type(of: $0) == ImageSidebarModel.self }) {
                return viewModel
            } else {
                let viewModel = ImageSidebarModelBuilder.build(store: imageStore, score: scoreController, coordinator: self)
                viewModels.append(viewModel)
                return viewModel
            }
        }
    }
}

extension ImageStripCoordinator {
    
}
