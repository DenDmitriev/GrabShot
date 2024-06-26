//
//  VideoGrabViewModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseCrashlytics

class VideoGrabViewModel: ObservableObject {
    @Published var grabState: VideoGrabState = .ready
    @Published var error: GrabError?
    @Published var hasError: Bool = false
    @Published var currentTimecode: Duration = .zero
    @Published var isProgress: Bool = false
    @AppStorage(DefaultsKeys.stripViewMode) var stripMode: StripMode = .liner
    var grabber: Grabber?
    var stripImageCreator: StripImageCreator?
    var stripColorManager: StripColorManager?
    weak var coordinator: GrabCoordinator?
    
    @AppStorage(DefaultsKeys.exportGrabbingImageFormat)
    private var exportGrabbingImageFormat: FileService.Format = .jpeg
    
    // MARK: Cut Video
    func cut(video: Video, from: Duration, to: Duration) {
        guard video.exportDirectory != nil else {
            coordinator?.presentAlert(error: .exportDirectoryFailure(title: video.title))
            coordinator?.showRequirements = true
            return
        }
        progress(is: true)
        FFmpegVideoService.cut(in: video, from: from, to: to, callBackProgress: { progress in
            DispatchQueue.main.async {
                // Update progress
                if video.progress.total != progress.total {
                    video.progress.total = progress.total
                }
                video.progress.current = min(progress.value, progress.total)
                
                // Update current timecode
                let seconds = video.rangeTimecode.lowerBound.seconds + (progress.percent * video.rangeTimecode.duration.seconds)
                self.currentTimecode = .seconds(seconds)
            }
        }) { [weak self] result in
            switch result {
            case .success(let urlVideo):
                print("success", urlVideo)
                Analytics.logEvent(
                    AnalyticsEvent.cutVideoFinish.key,
                    parameters: [
                        "cut_range": "\(from.seconds - to.seconds) / \(video.duration)"
                    ]
                )
            case .failure(let failure):
                if let failure = failure as? LocalizedError {
                    self?.presentError(failure)
                }
            }
            self?.progress(is: false)
        }
    }
    
    // MARK: Grabbing Video
    func grabbingRouter(for video: Video, period: Double) {
        guard video.exportDirectory != nil else {
            coordinator?.presentAlert(error: .exportDirectoryFailure(title: video.title))
            coordinator?.showRequirements = true
            return
        }
        switch grabState {
        case .ready, .complete, .canceled:
            startGrab(video: video, period: period)
        case .pause:
            resumeGrab()
        case .grabbing:
            pauseGrab()
        case .calculating:
            return
        }
    }
    
    private func didFinishGrabbing(for video: Video) {
        defer {
            Analytics.logEvent(
                AnalyticsEvent.grabFinish.key,
                parameters: [
                    "grab_period": UserDefaultsService.default.period,
                    "grab_count": video.progress.current
                ]
            )
        }
        defer {
            if UserDefaultsService.default.openDirToggle, let exportDirectory = video.exportDirectory {
                FileService.openDirectory(by: exportDirectory)
            }
        }
        createStripImage(for: video)
    }
    
    func startGrab(video: Video, period: Double) {
        progress(is: true)
        // Prepare
        video.reset()
        video.lastRangeTimecode = switch video.range {
        case .full:
            video.timelineRange
        case .excerpt:
            video.rangeTimecode
        }
        grabber = Grabber(video: video, period: period, format: exportGrabbingImageFormat, delegate: self)
        createStripManager()
        
        // Start
        grabber?.start()
    }
    
    func pauseGrab() {
        progress(is: false)
        grabber?.pause()
    }
    
    func resumeGrab() {
        progress(is: true)
        grabber?.resume()
    }
    
    func cancelGrab() {
        progress(is: false)
        grabber?.cancel()
    }
    
    private func didUpdate(video: Video, progress: Int, timecode: Duration, imageURL: URL) async {
        // Add colors to video
        await stripColorManager?.appendAverageColors(for: video, from: imageURL)
        
        DispatchQueue.main.async {
            // Update last range
            if let lastRangeTimecode = video.lastRangeTimecode {
                video.lastRangeTimecode = .init(uncheckedBounds: (lower: lastRangeTimecode.lowerBound, upper: timecode))
            }
            
            // Update progress
            video.progress.current = min(progress, video.progress.total)
            
            // Update current timcode
            self.currentTimecode = timecode
            
            // Check for complete
            if video.progress.total == video.progress.current {
                self.didFinishGrabbing(for: video)
                self.progress(is: false)
            }
        }
    }
    
    // MARK: StripManager
    private func createStripManager() {
        stripColorManager = StripColorManager(stripColorCount:  UserDefaultsService.default.stripCount)
    }
    
    // MARK: - StripCreator
    private func createStripImageCreator() {
        stripImageCreator = GrabStripCreator()
    }
    
    func createStripImage(for video: Video) {
        guard !video.grabColors.isEmpty,
              let url = video.exportDirectory
        else { return }
        
        let name = video.grabName + ".Strip"
        let exportURL = url.appendingPathComponent(name)
        
        let width = UserDefaultsService.default.stripSize.width
        let height = UserDefaultsService.default.stripSize.height
        let size = CGSize(width: width, height: height)
        
        createStripImageCreator()
        
        do {
            try stripImageCreator?.create(to: exportURL, with: video.grabColors, size: size, stripMode: stripMode, format: exportGrabbingImageFormat)
            Analytics.logEvent(
                AnalyticsEvent.grabFinish.key,
                parameters: [
                    "strip_size": size,
                    "count_colors": video.grabColors.count,
                    "strip_mode": stripMode.name,
                    "image_format": exportGrabbingImageFormat.rawValue
                ]
            )
        } catch let error as LocalizedError {
            self.presentError(error)
            Crashlytics.crashlytics().record(error: error, userInfo: ["function": #function, "object": type(of: self)])
        } catch {
            print(error.localizedDescription)
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
        Task {
            await didUpdate(video: video, progress: progress, timecode: timecode, imageURL: imageURL)
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
    
    func presentError(_ error: LocalizedError) {
        DispatchQueue.main.async {
            self.error = GrabError.map(errorDescription: error.localizedDescription, failureReason: error.failureReason)
            self.hasError = true
        }
    }
    
    func progress(is progress: Bool) {
        DispatchQueue.main.async {
            self.isProgress = progress
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
