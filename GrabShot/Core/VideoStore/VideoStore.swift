//
//  Session.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 19.11.2022.
//

import SwiftUI
import Combine

class VideoStore: ObservableObject {
    
    let userDefaults: UserDefaultsService = UserDefaultsService.default
    
    @Published var videos: [Video]
    
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
    
    private var store = Set<AnyCancellable>()
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
        self.videos.append(video)
        DispatchQueue.global(qos: .utility).async {
            self.getDuration(video)
        }
    }
    
    func deleteVideos(by ids: Set<UUID>, completion: @escaping (() -> Void)) {
        guard
            !ids.isEmpty
        else { return }
        
        let operation = BlockOperation {
            ids.forEach { id in
                DispatchQueue.main.async {
                    self.videos.removeAll(where: { $0.id == id })
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
    
    private func getDuration(_ video: Video) {
        DispatchQueue.main.async {
            self.isCalculating = true
        }
        
        VideoService.duration(for: video) { result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    video.duration = success
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
    }
}

extension VideoStore {
    var sortedVideos: [Video] {
        return self.videos
            .sorted(using: sortOrder)
    }
}
