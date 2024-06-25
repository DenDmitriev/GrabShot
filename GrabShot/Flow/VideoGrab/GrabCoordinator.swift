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
    @Published var showVideoImporter: Bool = false
    @Published var hasVideoHostingURL: Bool = false
    @Published var videoHostingURL: URL?
    @Published var showVideoExporter: Bool = false
    @Published var showMetadata: Bool = false
    @Published var showRequirements: Bool = false
    var metadata: MetadataVideo?
    var contextVideoId: Video.ID?
    
    init(videoStore: VideoStore, imageStore: ImageStore, scoreController: ScoreController) {
        self.videoStore = videoStore
        self.imageStore = imageStore
        self.scoreController = scoreController
        super.init(route: .grab)
    }
    
    func viewModel<ViewModel: ObservableObject>(type: ViewModel.Type, for route: GrabRouter) -> ViewModel? {
        for viewModel in self.viewModels {
            if let viewModel = viewModel as? ViewModel {
                return viewModel
            }
        }
        
        return buildViewModel(route) as? ViewModel
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

extension GrabCoordinator {
    func checkRequirements(for video: Video) {
        var isReady = true
        if video.exportDirectory == nil {
            isReady = false
        }
        
        DispatchQueue.main.async {
            self.showRequirements = !isReady
        }
    }
}
