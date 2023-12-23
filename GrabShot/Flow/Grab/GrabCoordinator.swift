//
//  GrabCoordinator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

class GrabCoordinator: Coordinator<GrabRouter, GrabError> {
    
    @ObservedObject var videoStore: VideoStore
    @ObservedObject var scoreController: ScoreController
    var videModels: [any ObservableObject] = []
    @Published var showVideoImporter: Bool = false
    
    init(videoStore: VideoStore, scoreController: ScoreController) {
        self.videoStore = videoStore
        self.scoreController = scoreController
        super.init(route: GrabRouter.grab)
    }
    
    override func buildViewModel(_ route: GrabRouter) -> (any ObservableObject)? {
        switch route {
        case .grab:
            let viewModel = GrabBuilder.build(store: videoStore, score: scoreController, coordinator: self)
            viewModels.append(viewModel)
            return viewModel
        case .rangePicker(videoId: _):
            return nil
        case .colorStrip:
            return nil
        }
    }
}

extension GrabCoordinator {
    func showFileImporter() {
        showVideoImporter = true
    }
    
    func fileImporter(result: Result<[URL], Error>) {
        videoStore.importVideo(result: result)
    }
}
