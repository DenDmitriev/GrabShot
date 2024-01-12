//
//  VideoGrabSidebarModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import Foundation

class VideoGrabSidebarModel: ObservableObject {
    var dropDelegate: VideoDropDelegate
    weak var coordinator: GrabCoordinator?
    @Published var error: GrabError?
    @Published var hasError: Bool = false
    @Published var isAnimate: Bool = false
    @Published var showDropZone: Bool = false
    
    init(dropDelegate: VideoDropDelegate) {
        self.dropDelegate = dropDelegate
    }
    
    // MARK: UI
    func updateCover(video: Video) {
        if video.images.isEmpty {
            getThumbnail(video: video, update: .init(url: video.coverURL))
        } else {
            video.updateCover()
        }
    }
    
    private func getThumbnail(video: Video, update: VideoService.UpdateThumbnail? = nil) {
        Task { [weak video] in
            guard let video else { return }
            VideoService.thumbnail(for: video, update: update) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    DispatchQueue.main.async {
                        video.coverURL = imageURL
                    }
                case .failure(let failure):
                    if let error = failure as? LocalizedError {
                        self?.error = GrabError.map(errorDescription: error.localizedDescription, recoverySuggestion: error.recoverySuggestion)
                        self?.hasError = true
                    }
                }
            }
        }
    }
}

extension VideoGrabSidebarModel {
    static func build(store: VideoStore, score: ScoreController, coordinator: GrabCoordinator? = nil) -> VideoGrabSidebarModel {
        let grabDropHandler = GrabDropHandler()
        let dropDelegate = VideoDropDelegate(store: store)
        let viewModel = VideoGrabSidebarModel(dropDelegate: dropDelegate)
        
        viewModel.coordinator = coordinator
        grabDropHandler.viewModel = viewModel
        dropDelegate.errorHandler = grabDropHandler
        dropDelegate.dropAnimator = grabDropHandler
        
        return viewModel
    }
}

extension VideoGrabSidebarModel: GrabModelDropHandlerOutput {
    
}
