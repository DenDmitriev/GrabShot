//
//  GrabModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.11.2022.
//

import SwiftUI

class GrabModel: ObservableObject {
    
    let videoService: VideoService
    @ObservedObject var session: Session

    @Published var status: Status
    @Published var grabbingID: Video.ID?
    @Published var isCalculated: Bool
    @Published var isLoading: Bool
    @Published var selection: Video.ID?
    @Published var passedShots: Double
    @Published var totalShots: Double
    
    var grabOperation: GrabOperation?
    var strip: NSImage?
    
    init() {
        self.videoService = VideoService()
        self.session = Session.shared
        self.status = Status(state: .ready)
        self.isCalculated = false
        self.isLoading = false
        self.totalShots = 1
        self.passedShots = 0
    }
    
    func calculate(for value: Video.Value) {
        self.isLoading = true
        self.status.change(.calculating)
        videoService.calculate(for: value, videos: &session.videos, period: session.period) { //videos in
            print("calculateVideo complete")
            self.isCalculated.toggle()
            self.isLoading = false
            self.status.change(.ready)
            DispatchQueue.main.async {
                self.totalShots = Double(self.allShotsCount())
            }
        }
    }
    
    func updatePeriod(_ period: Int) {
        session.userDefaults.savePeriod(period)
    }
    
    func start() {
        switch grabOperation?.operationQueue.isSuspended {
        case true:
            grabOperation?.operationQueue.isSuspended = false
            self.session.isGrabbing = true
            
        case .none, false:
            DispatchQueue.main.async {
                self.passedShots = 0.0
                self.session.isGrabbing = true
            }
            
            grabOperation = GrabOperation(session.videos, period: session.period)
            grabOperation?.delegate = self
            
            guard let video = session.videos.first else { return }
            grabOperation?.start(for: video.id)
            grabbingID = video.id
        case .some(_):
            return
        }
        self.status.change(.grabing)
    }
    
    func pause() {
        grabOperation?.operationQueue.isSuspended = true
        self.session.isGrabbing = false
        self.status.change(.pause)
    }
    
    func cancel() {
        grabOperation?.cancel {
            print(#function)
            self.session.isGrabbing = false
            self.session.videos.forEach {
                $0.progress = 0.0
                $0.colors = nil
            }
            self.status.change(.canceled)
        }
    }
    
    func delete(for id: Int?) {
        guard
            !session.isGrabbing,
            let id = id
        else { return }
        
        DispatchQueue.main.async {
            let passedShotDeletedVideo = self.session.videos.first{ $0.id == id }?.progress ?? 0
            let shotsDeletedVideo = Double(self.session.videos.first{ $0.id == id }?.shots(for: Session.shared.period) ?? 0)
            self.passedShots -= passedShotDeletedVideo
            self.totalShots -= shotsDeletedVideo
            self.session.videos.removeAll(where: { $0.id == id })
        }
    }
    
    func colors(id: Video.ID?) -> [Color]? {
        guard
            let id = id,
            let video = session.videos.first(where: { $0.id == id }),
            let colors = video.colors
        else { return nil }
        return colors
    }
}

extension GrabModel: GrabOperationDelegate {
    
    func start(videoID: Video.ID) {
        let additionally = self.log(title: self.session.videos.first{ $0.id == videoID }?.title ?? "", progress: Progress(current: 0, total: 100))
        DispatchQueue.main.async {
            self.grabbingID = videoID
            self.session.isGrabbing = true
            self.status.change(.grabing, additionally: additionally)
        }
    }
    
    func complete(video: Video) {
        if session.openDirToggle {
            FileService.shared.openDir(by: video.url.deletingPathExtension())
        }
        
        let stripModel = StripModel(video: video)
        let stripView = StripView(viewModel: stripModel)
        stripModel.saveImage(view: stripView)
    }
    
    func complete() {
        DispatchQueue.main.async {
            self.session.isGrabbing = false
            self.status.change(.complete, additionally: ", \(self.allShotsCount()) " + NSLocalizedString("shots grabbed", comment: ""))
        }
    }
    
    func progress(for video: Video, progress: Progress) {
        progressUpdate(video, progress)
        DispatchQueue.main.async {
            switch self.status.state {
            case .canceled:
                video.progress = 0.0
            case .grabing, .pause:
                self.status.additionally = self.log(title: video.title, progress: progress)
            default:
                break
            }
            
        }
    }
    
    //MARK: - Private funcs
    
    private func allShotsCount() -> Int {
        var count: Int = 0
        switch self.session.videos.isEmpty {
        case true:
            return 1
        case false:
            self.session.videos.forEach{ count += $0.shots(for: session.period) + 1 }
            return count
        }
    }
    
    private func progressUpdate(_ video: Video, _ progress: Progress) {
        DispatchQueue.main.async {
            Session.shared.videos.first{ $0.id == video.id }?.progress = Double(progress.current)
            self.passedShots += 1
            print("👾 \(self.passedShots)/\(self.totalShots)")
        }
    }
    
    private func log(title: String, progress: Progress) -> String {
        title + " " + progress.status
    }
}
