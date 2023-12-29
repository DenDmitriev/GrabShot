//
//  VideoGrabViewModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI
import Combine

class VideoGrabViewModel: ObservableObject {
    @Published var grabState: VideoGrabState = .ready
    @Published var error: GrabError?
    @Published var hasError: Bool = false
    @Published var currentTimecode: Duration = .zero
    @AppStorage(DefaultsKeys.stripViewMode) var stripMode: StripMode = .liner
    var grabber: Grabber?
    var stripImageCreator: StripImageCreator?
    var stripColorManager: StripColorManager?
    weak var coordinator: GrabCoordinator?
    
    // MARK: Grabbing
    func grabbingRouter(for video: Video, period: Int) {
        guard video.exportDirectory != nil else {
            coordinator?.presentAlert(error: .exportDirectoryFailure(title: video.title))
            return
        }
        switch grabState {
        case .ready, .complete, .canceled:
            start(video: video, period: period)
        case .pause:
            resume()
        case .grabbing:
            pause()
        case .calculating:
            return
        }
    }
    
    private func didFinishGrabbing(for video: Video) {
        createStripImage(for: video)
    }
    
    // MARK: Grabber
    func start(video: Video, period: Int) {
        // Prepare
        video.reset()
        video.lastRangeTimecode = switch video.range {
        case .full:
            video.timelineRange
        case .excerpt:
            video.rangeTimecode
        }
        grabber = Grabber(video: video, period: period, delegate: self)
        createStripManager()
        
        // Start
        grabber?.start()
    }
    
    func pause() {
        grabber?.pause()
    }
    
    func resume() {
        grabber?.resume()
    }
    
    func cancel() {
        grabber?.cancel()
    }
    
    // MARK: StripManager
    private func createStripManager() {
        stripColorManager = StripColorManager(stripColorCount:  UserDefaultsService.default.stripCount)
    }
    
    private func getColors(from imageURL: URL, in video: Video, completion: @escaping (() -> Void)) {
        Task {
            await self.stripColorManager?.appendAverageColors(for: video, from: imageURL) {
                completion()
            }
        }
    }
    
    // MARK: - StripCreator
    private func createStripImageCreator() {
        stripImageCreator = GrabStripCreator()
    }
    
    func createStripImage(for video: Video) {
        guard !video.colors.isEmpty,
              let url = video.exportDirectory
        else { return }
        
        let name = video.grabName + ".Strip"
        let exportURL = url.appendingPathComponent(name)
        
        let width = UserDefaultsService.default.stripSize.width
        let height = UserDefaultsService.default.stripSize.height
        let size = CGSize(width: width, height: height)
        
        createStripImageCreator()
        
        do {
            try stripImageCreator?.create(to: exportURL, with: video.colors, size: size, stripMode: stripMode)
        } catch {
            if let error = error as? LocalizedError {
                self.hasError(error)
            }
        }
    }
}

extension VideoGrabViewModel: GrabDelegate {
    func started(video: Video, progress: Int, total: Int) {
        DispatchQueue.main.async {
            video.progress.total = total
            video.progress.current = progress
            self.grabState = .grabbing
        }
    }
    
    func didPause() {
        DispatchQueue.main.async {
            self.grabState = .pause
        }
    }
    
    func didResume() {
        DispatchQueue.main.async {
            self.grabState = .grabbing
        }
    }
    
    func didUpdate(video: Video, progress: Int, timecode: Duration, imageURL: URL) {
        // До обновления нужно получить цвета из изображения
        getColors(from: imageURL, in: video) { [weak self] in
            DispatchQueue.main.async {
                video.progress.current = min(progress, video.progress.total)
                self?.currentTimecode = timecode
                
                if video.progress.total == video.progress.current {
                    self?.didFinishGrabbing(for: video)
                }
            }
        }
    }
    
    func completed(video: Video, progress: Int) {
        DispatchQueue.main.async {
            self.grabState = .complete(shots: progress)
        }
        grabber = nil
    }
    
    func canceled() {
        DispatchQueue.main.async {
            self.grabState = .canceled
        }
        stripColorManager = nil
        grabber = nil
    }
    
    func hasError(_ error: LocalizedError) {
        DispatchQueue.main.async {
            self.error = GrabError.map(errorDescription: error.localizedDescription, recoverySuggestion: error.recoverySuggestion)
            self.hasError = true
        }
    }
}

extension VideoGrabViewModel {
    static func build(store: VideoStore, score: ScoreController, coordinator: GrabCoordinator? = nil) -> VideoGrabViewModel {
        
        let viewModel = VideoGrabViewModel()
        
        viewModel.coordinator = coordinator
        
        return viewModel
    }
}
