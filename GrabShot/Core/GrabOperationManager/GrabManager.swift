//
//  GrabOperationManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import SwiftUI

protocol GrabManagerDelegate: AnyObject {
    func hasError(_ error: Error)
    func started(video: Video)
    func progress(for video: Video, isCreated: Int, on timecode: TimeInterval, by url: URL)
    func completed(for video: Video)
    func completedAll(grab count: Int)
}

class GrabManager {
    typealias Timecode = TimeInterval
    
    var videoStore: VideoStore
    var videos: [Video] {
        videoStore.sortedVideos.filter({ $0.isEnable == true })
    }
    weak var delegate: GrabManagerDelegate?
    
    private var videoService: VideoService
    private var period: Int
    private var stripColorCount: Int
    private var timecodes: [ UUID : [Timecode] ]
    private var error: Error?
    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    private var grabCounter: Int = .zero
    
    init(videoStore: VideoStore, period: Int, stripColorCount: Int) {
        self.videoStore = videoStore
        self.videoService = VideoService()
        self.period = period
        self.stripColorCount = stripColorCount
        self.timecodes = [:]
    }
    
    //MARK: - Public control
    
    func start() throws {
        guard let firstID = videos.first?.id else { return }
        try start(for: firstID)
    }
    
    func pause() {
        operationQueue.isSuspended = true
    }
    
    func resume() {
        operationQueue.isSuspended = false
    }
    
    func cancel() {
        self.operationQueue.cancelAllOperations()
    }
    
    
    func isPaused() -> Bool {
        operationQueue.isSuspended
    }
    
    //MARK: - Private
    
    private func start(for id: UUID, flags: [Flag] = [.autoAddImageGrabbing]) throws {
        guard let video = videos.first(where: { $0.id == id }) else { return }
        
        guard let exportDirectory = video.exportDirectory else {
            delegate?.completed(for: video)
            let error = GrabError.exportDirectory(title: video.title)
            throw error
        }
        
        guard FileManager.default.fileExists(atPath: exportDirectory.relativePath) else {
            delegate?.completed(for: video)
            let error = GrabError.exportDirectory(title: video.title)
            throw error
        }
        
        let operations = createOperations(for: video, with: period, flags: flags)
        operations.forEach { operation in
            operationQueue.addOperation(operation)
        }
        
        delegate?.started(video: video)
    }
    
    private func createOperations(for video: Video, with period: Int, flags: [Flag] = []) -> [GrabOperation] {
        let timecodes = timecodes(for: video)
        self.timecodes[video.id] = timecodes
        let grabOperations = timecodes.map { timecode in
            let grabOperation = GrabOperation(video: video, timecode: timecode, quality: UserDefaultsService.default.quality)
            grabOperation.completionBlock = { [weak self] in
                if let result = grabOperation.result {
                    switch result {
                    case .success(let success):
                        let imageURL = success
                        self?.options(on: flags, video: video, imageURL: imageURL)
                        DispatchQueue.main.async {
                            self?.grabCounter += 1
                            video.progress.current += 1
                        }
                        self?.delegate?.progress(for: video, isCreated: video.progress.current, on: timecode, by: imageURL)
                    case .failure(let failure):
                        self?.error = failure
                        self?.delegate?.hasError(failure)
                    }
                }
                
                do {
                    try self?.onNextOperation(for: video, flags: flags)
                } catch let error {
                    self?.delegate?.hasError(error)
                }
            }
            return grabOperation
        }
        return grabOperations
    }
    
    private func options(on flags: [Flag], video: Video, imageURL: URL) {
        flags.forEach { [weak self] flag in
            switch flag {
            case .autoAddImageGrabbing:
                self?.addImage(to: video, by: imageURL)
            }
        }
    }
    
    private func addImage(to video: Video, by url: URL) {
        video.images.append(url)
    }
    
    private func timecodes(for video: Video) -> [Timecode] {
        let shotsCount = video.progress.total
        var timecodes = [Timecode]()
        
        for shot in 0..<shotsCount {
            let startTimecode: TimeInterval
            switch video.range {
            case .full:
                startTimecode = .zero
            case .excerpt:
                startTimecode = video.fromTimecode.timeInterval
            }
            let timecode = startTimecode + Double(shot * period)
            timecodes.append(timecode)
        }
        return timecodes
    }
    
    private func onNextOperation(for video: Video, flags: [Flag]) throws {
        if isGrabCompleteForCurrentVideo() {
            self.delegate?.completed(for: video)
            
            if self.isLastVideoFromSession(video: video) {
                self.delegate?.completedAll(grab: grabCounter)
            } else {
                guard let currentIndex = videos.firstIndex(of: video) else { return }
                let nextIndex = videos.index(after: currentIndex)
                guard videos.indices ~= nextIndex else { return }
                let nextId = videos[nextIndex].id
                try self.start(for: nextId, flags: flags)
            }
        }
    }
    
    private func isGrabCompleteForCurrentVideo() -> Bool {
        return self.operationQueue.operationCount == .zero ? true : false
    }
    
    private func isLastVideoFromSession(video: Video) -> Bool {
        return video.id == videos.last?.id || videos.isEmpty
    }
}

extension GrabManager {
    enum Flag {
        case autoAddImageGrabbing
    }
}
