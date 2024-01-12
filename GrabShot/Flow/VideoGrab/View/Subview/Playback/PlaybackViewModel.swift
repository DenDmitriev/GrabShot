//
//  TimecodePickerModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 11.12.2023.
//

import Foundation
import AVKit

class PlaybackViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isProgress: Bool = false
    @Published var progress: Double = .zero
    @Published var error: VideoPlayerError?
    @Published var timeObserver: Any?
    
    private var playerObservers: [NSKeyValueObservation?] = []
    
    func addObserver(observer: NSKeyValueObservation?) {
        playerObservers.append(observer)
    }
    
    func removeObserver(for player: AVPlayer?) {
        playerObservers.forEach({ $0?.invalidate() })
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
    
    func cache(video: Video, completion: @escaping ((URL?) -> Void)) {
        updateProgress(true)
        DispatchQueue.global(qos: .userInitiated).async { 
            VideoService.cache(for: video) { [weak self] result in
                self?.updateProgress(false)
                switch result {
                case .success(let success):
                    completion(success)
                    DispatchQueue.main.async {
                        video.cacheUrl = success
                    }
                case .failure(let failure):
                    if let error = failure as? LocalizedError {
                        self?.hasError(error)
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func fetchVideoColors(video: Video) {
        guard video.timelineColors.isEmpty else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.updateProgress(true)
            Task {
                do {
                    try await video.fetchTimelineColors() { [weak self] progress, timecode in
                        self?.progress = progress
                        if progress >= 1 {
                            self?.updateProgress(false)
                        }
                    }
                } catch let error {
                    self.hasError(error)
                }
            }
        }
    }
    
    private func updateProgress(_ progress: Bool) {
        DispatchQueue.main.async {
            self.isProgress = progress
        }
    }
    
    private func hasError(_ error: Error) {
        DispatchQueue.main.async {
            let error = error as NSError
            self.error = VideoPlayerError.map(errorDescription: error.localizedDescription, failureReason: error.localizedFailureReason)
        }
    }
}
