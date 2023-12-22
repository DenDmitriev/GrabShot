//
//  GrabCoordinator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

class GrabCoordinator: Coordinator<GrabRouter> {
    
    @ObservedObject var videoStore: VideoStore
    @ObservedObject var scoreController: ScoreController
    
    init(videoStore: VideoStore, scoreController: ScoreController) {
        self.videoStore = videoStore
        self.scoreController = scoreController
        super.init(route: GrabRouter.grab)
    }
    
    override func buildViewModel(_ route: GrabRouter) -> (any ObservableObject)? {
        switch route {
        case .grab:
            GrabBuilder.build(store: videoStore, score: scoreController)
        case .rangePicker(videoId: _):
            nil
        case .empty:
            nil
        }
    }
}
