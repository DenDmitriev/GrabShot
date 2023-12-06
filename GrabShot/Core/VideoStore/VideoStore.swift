//
//  Session.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 19.11.2022.
//

import SwiftUI

class VideoStore: ObservableObject {
    
    let userDefaults: UserDefaultsService = UserDefaultsService.default
    
    @Published var videos: [Video]
    
    @Published var addedVideo: Video?

    
    @Published var period: Int {
        didSet {
            userDefaults.savePeriod(period)
        }
    }
    
    @Published var isCalculating: Bool = false
    @Published var isGrabbing: Bool = false
    @Published var isGrabEnable: Bool = false
    
    @Published var error: GrabShotError?
    @Published var showAlert = false
    
    @Published var sortOrder: [KeyPathComparator<Video>] = [keyPathComparator]
    
    static let keyPathComparator = KeyPathComparator<Video>(\.title, order: SortOrder.forward)
    
    private var backgroundGlobalQueue = DispatchQueue.global(qos: .background)
    
    init() {
        videos = []
        period = userDefaults.period
        userDefaults.saveFirstInitDate()
    }
    
    subscript(videoId: Video.ID?) -> Video {
        get {
            if let video = videos.first(where: { $0.id == videoId }) {
                return video
            } else {
                return .placeholder
            }
        }
        
        set(newValue) {
            if let index = videos.firstIndex(where: { $0.id == newValue.id }) {
                videos[index] = newValue
            }
        }
    }
    
    func addVideo(video: Video) {
        videos.append(video)
        addedVideo = video
        DispatchQueue.global(qos: .utility).async {
            self.getMetadata(video)
//            self.getDuration(video)
        }
    }
    
    func deleteVideos(by ids: Set<UUID>, completion: @escaping (() -> Void)) {
        guard
            !ids.isEmpty
        else { return }
        
        let operation = BlockOperation {
            ids.forEach { [weak self] id in
                // Удаление всех подписок видео
                let video = self?[id]
                video?.willDelete()
                
                if self?.addedVideo == video {
                    self?.addedVideo = nil
                }
                
                DispatchQueue.main.async {
                    self?.videos.removeAll(where: { $0.id == id })
                }
            }
        }
        operation.completionBlock = {
            completion()
        }
        
        DispatchQueue.main.async {
            operation.start()
        }
    }
    
    func presentError(error: LocalizedError) {
        let error = GrabShotError.map(errorDescription: error.errorDescription, recoverySuggestion: error.recoverySuggestion)
        DispatchQueue.main.async {
            self.error = error
            self.showAlert = true
        }
    }
    
    func updateIsGrabEnable() {
        let isEnable = !videos.filter { video in
            video.isEnable && video.exportDirectory != nil
        }.isEmpty
        
        DispatchQueue.main.async { [weak self] in
            self?.isGrabEnable = isEnable
        }
    }
    
    // MARK: - Private methods
    
    private func getMetadata(_ video: Video) {
        DispatchQueue.main.async {
            self.isCalculating = true
        }
        
        let result = VideoService.getMetadata(of: video)
        switch result {
        case .success(let metadata):
            DispatchQueue.main.async {
                video.metadata = metadata
                if let duration = metadata.format.duration {
                    video.duration = duration
                } else {
                    self.getDuration(video)
                }
                self.isCalculating = false
            }
        case .failure(let failure):
            DispatchQueue.main.async {
                self.error = .map(errorDescription: failure.localizedDescription, recoverySuggestion: nil)
                self.showAlert = true
                self.isCalculating = false
            }
        }
    }
    
    private func getDuration(_ video: Video) {
        DispatchQueue.main.async {
            self.isCalculating = true
        }
        
        VideoService.duration(for: video) { [weak self] result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    video.duration = success
                    self?.isCalculating = false
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = .map(errorDescription: failure.localizedDescription, recoverySuggestion: nil)
                    self?.showAlert = true
                    self?.isCalculating = false
                }
            }
        }
    }
}

extension VideoStore {
    var sortedVideos: [Video] {
        self.videos
            .sorted(using: sortOrder)
    }
}
