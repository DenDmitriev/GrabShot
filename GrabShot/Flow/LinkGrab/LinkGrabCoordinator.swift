//
//  LinkGrabCoordinator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.01.2024.
//

import SwiftUI

class LinkGrabCoordinator: Coordinator<LinkGrabRouter, GrabError> {
    @ObservedObject var imageStore: ImageStore
    @ObservedObject var scoreController: ScoreController
    var videModels: [any ObservableObject] = []
    @Published var showVideoExporter: Bool = false
    
    init(imageStore: ImageStore, scoreController: ScoreController) {
        self.imageStore = imageStore
        self.scoreController = scoreController
        super.init(route: .grab)
    }
    
    override func buildViewModel(_ route: LinkGrabRouter) -> (any ObservableObject)? {
        switch route {
        case .grab:
            if let viewModel = viewModels.first(where: { type(of: $0) == LinkVideoViewModel.self }) {
                return viewModel
            } else {
                let viewModel = LinkVideoViewModel.build(score: scoreController, coordinator: self)
                viewModels.append(viewModel)
                return viewModel
            }
        }
    }
}
