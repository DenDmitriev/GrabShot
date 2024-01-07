//
//  Session.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 19.11.2022.
//

import SwiftUI
import MetadataVideoFFmpeg

class VideoStore: ObservableObject {
    
    let userDefaults: UserDefaultsService = UserDefaultsService.default
    
    @Published var videos: [Video]
    @Published var selectedVideos = Set<Video.ID>()
    
    @Published var addedVideo: Video?

    
    @Published var period: Int {
        didSet {
            userDefaults.savePeriod(period)
        }
    }
    
    @Published var isCalculating: Bool = false
    @Published var isGrabbing: Bool = false
    @Published var isGrabEnable: Bool = false
    
    @Published var error: AppError?
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
    
    func importVideo(result: Result<[URL], Error>) {
        switch result {
        case .success(let success):
            success.forEach { url in
                let isTypeVideoOk = FileService.shared.isTypeVideoOk(url)
                switch isTypeVideoOk {
                case .success(_):
                    if url.startAccessingSecurityScopedResource() {
                        let video = Video(url: url, store: self)
                        addVideo(video: video)
                    }
                case .failure(let failure):
                    presentError(error: failure)
                }
            }
        case .failure(let failure):
            if let failure = failure as? LocalizedError {
                presentError(error: failure)
            }
        }
    }
    
    func exportVideo(result: Result<URL, Error>, for video: Video, completion: @escaping (() -> Void)) {
        switch result {
        case .success(let directory):
            if let oldExportDirectory = video.exportDirectory {
                oldExportDirectory.stopAccessingSecurityScopedResource()
            }
            
            let gotAccess = directory.startAccessingSecurityScopedResource()
            if !gotAccess { return }
            
            video.exportDirectory = directory
        case .failure(let failure):
            if let failure = failure as? LocalizedError {
                presentError(error: failure)
            }
        }
        completion()
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
                
                video?.url.stopAccessingSecurityScopedResource()
                
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
        let error = AppError.map(errorDescription: error.errorDescription, recoverySuggestion: error.recoverySuggestion)
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
                
                // Установим размер видео в пикселях
                if let size = self.getSize(metadata: metadata) {
                    video.size = size
                    video.aspectRatio =  size.width / size.height
                }
                
                // Установим длительность
                if let duration = metadata.format.duration {
                    video.duration = TimeInterval(duration.components.seconds)
                } else {
                    self.getDuration(video)
                }
                
                // Установим кол-во кадров в секунду
                if let frameRate = metadata.streams
                    .first(where: { $0.codecType == .video })?
                    .frameRate {
                    video.frameRate = frameRate
                }
                
                self.isCalculating = false
            }
        case .failure(let failure):
            DispatchQueue.main.async {
                self.error = .map(errorDescription: failure.localizedDescription, recoverySuggestion: failure.recoverySuggestion)
                self.showAlert = true
                self.isCalculating = false
                self.getDuration(video)
            }
        }
    }
    
    private func getSize(metadata: MetadataVideo?) -> CGSize? {
        guard let stream = metadata?.streams.first(where: { $0.codecType == .video }),
              let width = stream.width,
              let height = stream.height
        else { return nil }
        return .init(width: width, height: height)
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
