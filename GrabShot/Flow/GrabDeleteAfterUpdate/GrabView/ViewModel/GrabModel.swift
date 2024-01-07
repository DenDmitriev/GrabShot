//
//  GrabModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.11.2022.
//

import SwiftUI
import Combine

class GrabModel: ObservableObject, GrabModelGrabOutput, GrabModelDropHandlerOutput {
    
    // MARK: - Properties
    weak var coordinator: GrabCoordinator?
    @ObservedObject var videoStore: VideoStore
    @ObservedObject var progress: Progress = .init(total: 1)
    
    @Published var grabState: GrabState = .ready
    @Published var grabbingID: Video.ID?
    @Published var durationGrabbing: TimeInterval = .zero
    @Published var error: GrabError?
    @Published var hasError: Bool = false
    @Published var isAnimate: Bool = false
    @Published var showDropZone: Bool = false
    
    @AppStorage(DefaultsKeys.createStrip) var createStrip: Bool = true
    @AppStorage(DefaultsKeys.stripViewMode) var stripMode: StripMode = .liner
    
    var dropDelegate: VideoDropDelegate
    
    var stripImageCreator: StripImageCreator?
    var stripColorManager: StripColorManager?
    
    var grabManager: GrabManager?
    var grabManagerDelegate: GrabManagerDelegate?
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    private var timerCancellable: AnyCancellable?
    
    private var videoCancellable = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        videoStore: VideoStore,
        dropDelegate: VideoDropDelegate,
        stripCreator: GrabStripCreator,
        grabManagerDelegate: GrabManagerDelegate,
        grabManager: GrabManager
    ) {
        self.videoStore = videoStore
        self.dropDelegate = dropDelegate
        self.stripImageCreator = stripCreator
        self.grabManagerDelegate = grabManagerDelegate
        self.grabManager = grabManager
    }
    
    // MARK: - Functions
    
    // MARK: - Grab control functions
    
    func grabbingButtonRouter() {
        switch grabState {
        case .ready, .complete, .canceled:
            start()
        case .pause:
            resume()
        case .grabbing:
            pause()
        case .calculating:
            return
        }
    }
    
    func start() {
        createGrabManager()
        createStripManager()
        
        clearDataForViews()
        
        guard
            let video = grabManager?.videos.first,
            startAccessingForExportDirectory(for: video)
        else { return }
        
        createTimer()
        
        self.videoStore.isGrabbing = true
        self.grabState = .grabbing(log: buildLog(video: video))
        
        setGrabbingId(current: video)
        
        do {
            try grabManager?.start()
        } catch let error {
            cancelGrab(for: video)
            hasError(error)
        }
    }
    
    func resume() {
        guard
            grabManager != nil,
            let id = grabbingID,
            let video = grabManager?.videos.first(where: { $0.id == id })
        else { return }
        
        createTimer()
        
        videoStore.isGrabbing = true
        grabState = .grabbing(log: buildLog(video: video))
        
        grabManager?.resume()
    }
    
    func pause() {
        guard grabManager != nil else { return }
        
        grabManager?.pause()
        
        videoStore.isGrabbing = false
        grabState = .pause()
    }
    
    func cancel() {
        videoStore.isGrabbing = false
        grabState = .canceled
        grabManager?.cancel()
        grabManager = nil
        stripColorManager = nil
        clearDataForViews()
        cancelTimer()
    }
    
    // MARK: - Video actions methods
    
    func didAppendVideo(video: Video) {
        bind(on: video)
    }
    
    func didDeleteVideos(by selection: Set<UUID>) {
        guard
            !isDisabledUIForUserInterActive(by: grabState)
        else { return }
        
        videoStore.deleteVideos(by: selection) { [weak self] in
            self?.videoStore.updateIsGrabEnable()
            self?.updateProgress()
        }
    }
    
    func getColorsVideo(id: Video.ID?) -> [Color]? {
        guard
            let id = id,
            let video = videoStore.videos.first(where: { $0.id == id })
        else { return nil }
        
        return video.grabColors
    }
    
    // MARK: - UI methods
    
    func getTitleForGrabbingButton() -> String {
        let title: String
        switch grabState {
        case .ready, .calculating, .complete, .canceled:
            title = "Start"
        case .grabbing:
            title = "Pause"
        case .pause:
            title = "Resume"
        }
        return NSLocalizedString(title, comment: "Button title")
    }
    
    func isEnableCancelButton() -> Bool {
        switch grabState {
        case .ready, .calculating, .canceled, .complete:
            return false
        case .grabbing, .pause:
            return true
        }
    }
    
    func isDisableRemoveButton() -> Bool {
        videoStore.videos.isEmpty || videoStore.isGrabbing || videoStore.isCalculating
    }
    
    func updateProgress() {
        let totalShots: Int
        let currentShots: Int
        switch grabState {
        case .grabbing:
            guard let grabManager else { fallthrough }
            totalShots = grabManager.videos
                .map { video in
                    video.progress.total
                }
                .reduce(.zero) { $0 + $1 }
            
            currentShots = grabManager.videos
                .map { video in
                    video.progress.current
                }
                .reduce(.zero) { $0 + $1 }
        default:
            totalShots = videoStore.videos
                .filter { video in
                    video.isEnable
                }
                .map { video in
                    video.progress.total
                }
                .reduce(.zero) { $0 + $1 }
            
            currentShots = videoStore.videos
                .filter { video in
                    video.isEnable
                }
                .map { video in
                    video.progress.current
                }
                .reduce(.zero) { $0 + $1 }
        }
        DispatchQueue.main.async {
            self.progress.current = currentShots
            self.progress.total = totalShots
        }
    }
    
    // MARK: - Strip methods
    
    func createStripImage(for video: Video) {
        guard !video.grabColors.isEmpty,
              let url = video.exportDirectory
        else { return }
        
        let name = video.title + "Strip"
        let exportURL = url.appendingPathComponent(name)
        
        let width = UserDefaultsService.default.stripSize.width
        let height = UserDefaultsService.default.stripSize.height
        let size = CGSize(width: width, height: height)
        
        do {
            try stripImageCreator?.create(to: exportURL, with: video.grabColors, size: size, stripMode: stripMode)
        } catch {
            self.hasError(error)
        }
    }
    
    // MARK: - Error methods
    
    func hasError(_ error: Error) {
        DispatchQueue.main.async {
            if let localizedError = error as? LocalizedError {
                self.error = GrabError.map(errorDescription: localizedError.localizedDescription, recoverySuggestion: localizedError.recoverySuggestion)
            } else {
                self.error = GrabError.unknown
            }
            self.hasError = true
            
            self.coordinator?.presentAlert(error: self.error ?? GrabError.unknown)
        }
    }
    
    // MARK: - Private helpers functions
    
    func didStartedGrab(video: Video) {
        DispatchQueue.main.async {
            self.grabbingID = video.id
            self.videoStore.isGrabbing = true
            self.grabState = .grabbing(log: self.buildLog(video: video))
        }
    }
    
    func didUpdatedProgress(video: Video, by url: URL) {
        DispatchQueue.main.async {
            switch self.grabState {
            case .canceled:
                video.progress.current = .zero
            case .grabbing, .pause:
                self.progress.current += 1
                
                Task {
                    await self.stripColorManager?.appendAverageColors(for: video, from: url)
                }
                
                let log = self.buildLog(video: video)
                if self.grabState == .pause() {
                    self.grabState = .pause(log: log)
                } else {
                    self.grabState = .grabbing(log: log)
                }
            default:
                return
            }
        }
    }
    
    func didCompleted(for video: Video) {
        if UserDefaultsService.default.openDirToggle {
            if let exportDirectory = video.exportDirectory {
                FileService.openDirectory(by: exportDirectory)
            }
            video.exportDirectory?.stopAccessingSecurityScopedResource()
        }
        
        DispatchQueue.main.async {
            if video.progress.current == video.progress.total {
                video.isEnable = false
            }
        }
        
        createStripImage(for: video)
    }
    
    func didCompletedAll() {
        DispatchQueue.main.async {
            self.videoStore.updateIsGrabEnable()
            self.grabState = .complete(shots: self.progress.total)
            self.videoStore.isGrabbing = false
            self.stripColorManager = nil
        }
    }
    
    private func cancelGrab(for video: Video) {
        DispatchQueue.main.async {
            self.grabbingID = nil
            video.isEnable = false
            self.grabState = .canceled
        }
    }
    
    private func setGrabbingId(current video: Video) {
        grabbingID = video.id
    }
    
    private func startAccessingForExportDirectory(for video: Video) -> Bool {
        guard
            let gotAccess = video.exportDirectory?.startAccessingSecurityScopedResource(),
            gotAccess
        else {
            hasError(GrabError.accessFailure)
            return false
        }
        return gotAccess
    }
    
    private func isDisabledUIForUserInterActive(by state: GrabState) -> Bool {
        switch state {
        case .ready, .canceled, .complete:
            return false
        case .calculating, .grabbing, .pause:
            return true
        }
    }
    
    private func clearDataForViews() {
        durationGrabbing = .zero
        progress.current = .zero
        videoStore.videos
            .filter { $0.isEnable }
            .forEach { video in
            video.reset()
        }
    }
    
    // MARK: - Builders
    
    private func createGrabManager() {
        grabManager = GrabManager(videoStore: videoStore, period: videoStore.period, stripColorCount: UserDefaultsService.default.stripCount)
        grabManager?.delegate = grabManagerDelegate
    }
    
    private func createStripManager() {
        stripColorManager = StripColorManager(stripColorCount:  UserDefaultsService.default.stripCount)
    }
    
    // MARK: - Timer methods
    
    private func createTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        bindOnTimer()
    }
    
    private func cancelTimer() {
        timerCancellable = nil
        timer = nil
    }
    
    private func bindOnTimer() {
        timerCancellable = timer?
            .sink { [weak self] date in
                switch self?.grabState {
                case .grabbing:
                    self?.durationGrabbing += 1
                case .complete, .pause:
                    self?.timer?.upstream.connect().cancel()
                default:
                    return
                }
            }
    }
    
    // MARK: - Reactive update from video
    // TODO: Refactoring
    private func bind(on video: Video) {
        var cancellable: AnyCancellable?
        cancellable = video.$didUpdatedProgress
            .sink { [weak self] _ in
                self?.updateProgress()
            }
        
        if let cancellable {
            videoCancellable.insert(cancellable)
            video.cancellable.insert(cancellable)
        }
    }

    // MARK: - Log for view
    func buildLog(video: Video?) -> String {
        guard let video = video else { return "" }
        let title = video.title
        let progress = video.progress
        return title + " – " + progress.status
    }
}
