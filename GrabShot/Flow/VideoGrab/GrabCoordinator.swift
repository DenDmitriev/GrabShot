//
//  GrabCoordinator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI
import MetadataVideoFFmpeg

class GrabCoordinator: Coordinator<GrabRouter, GrabError> {
    
    @ObservedObject var videoStore: VideoStore
    @ObservedObject var imageStore: ImageStore
    @ObservedObject var scoreController: ScoreController
    var videModels: [any ObservableObject] = []
    @Published var showVideoImporter: Bool = false
    @Published var hasVideoHostingURL: Bool = false
    @Published var videoHostingURL: URL?
    @Published var showVideoExporter: Bool = false
    @Published var showMetadata: Bool = false
    var metadata: MetadataVideo?
    var contextVideoId: Video.ID?
    
    init(videoStore: VideoStore, imageStore: ImageStore, scoreController: ScoreController) {
        self.videoStore = videoStore
        self.imageStore = imageStore
        self.scoreController = scoreController
        super.init(route: .grab)
    }
    
    override func buildViewModel(_ route: GrabRouter) -> (any ObservableObject)? {
        switch route {
        case .grab:
            if let viewModel = viewModels.first(where: { type(of: $0) == VideoGrabSidebarModel.self }) {
                return viewModel
            } else {
                let viewModel = VideoGrabSidebarModel.build(store: videoStore, score: scoreController, coordinator: self)
                viewModels.append(viewModel)
                return viewModel
            }
        case .colorStrip:
            return nil
        }
    }
}

extension GrabCoordinator {
    func showFileImporter() {
        showVideoImporter = true
    }
    
    func showFileExporter(for videoId: Video.ID) {
        contextVideoId = videoId
        showVideoExporter = true
    }
    
    func fileImporter(result: Result<[URL], Error>) {
        videoStore.importVideo(result: result)
    }
    
    func hostingImporter(url: URL?) async {
        guard let url else { return }
        await videoStore.importHostingVideo(by: url)
        hasVideoHostingURL = false
    }
    
    func fileExporter(result: Result<URL, Error>, for video: Video) {
        videoStore.exportVideo(result: result, for: video) { [weak self] in
            self?.contextVideoId = nil
        }
    }
    
    func openWindow(metadata: MetadataVideo?) {
        self.metadata = metadata
        showMetadata = true
    }
}
