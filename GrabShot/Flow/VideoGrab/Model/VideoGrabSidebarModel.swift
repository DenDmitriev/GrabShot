//
//  VideoGrabSidebarModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import Foundation

class VideoGrabSidebarModel: ObservableObject {
    weak var dropDelegate: VideoDropDelegate?
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
            getThumbnail(video: video)
        } else {
            video.updateCover()
        }
    }
    
    private func getThumbnail(video: Video) {
        Task { [weak video] in
            guard let video else { return }
            FFmpegVideoService.thumbnail(for: video) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    DispatchQueue.main.async {
                        video.coverURL = imageURL
                    }
                case .failure(let failure):
                    let error = failure as NSError
                    self?.error = GrabError.map(errorDescription: error.localizedDescription, failureReason: error.localizedFailureReason)
                    self?.hasError = true
                    
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
