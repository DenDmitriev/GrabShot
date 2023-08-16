//
//  GrabOperationManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import SwiftUI

protocol GrabOperationManagerDelegate: AnyObject {
    func started(video: Video)
    func progress(for video: Video, isCreated: Int, on timecode: TimeInterval, by url: URL)
    func completed(for video: Video)
    func completedAll()
    func error(_ error: Error)
}

class GrabOperationManager {
    typealias Timecode = TimeInterval
    
    var videos = [Video]()
    weak var delegate: GrabOperationManagerDelegate?
    
    private var videoService: VideoService
    private var period: Int
    private var stripColorCount: Int
    private var timecodes: [ Int : [Timecode] ]
    private var error: Error?
    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    init(videos: [Video], period: Int, stripColorCount: Int) {
        self.videos = videos
        self.videoService = VideoService()
        self.period = period
        self.stripColorCount = stripColorCount
        self.timecodes = [:]
    }
    
    //MARK: - Public control
    
    func start() {
        guard let firstID = videos.first?.id else { return }
        start(for: firstID)
    }
    
    func pause() {
        operationQueue.isSuspended = true
    }
    
    func resume() {
        operationQueue.isSuspended = false
    }
    
    func cancel() {
        self.videos.removeAll()
        self.operationQueue.cancelAllOperations()
    }
    
    
    func isPaused() -> Bool {
        operationQueue.isSuspended
    }
    
    //MARK: - Private
    
    private func start(for id: Int) {
        guard let video = videos.first(where: { $0.id == id }) else { return }
        
        let operations = createOperations(for: video, with: period)
        operations.forEach { operation in
            operationQueue.addOperation(operation)
        }
        
        delegate?.started(video: video)
    }
    
    private func createOperations(for video: Video, with period: Int) -> [GrabOperation] {
        let timecodes = timecodes(for: video)
        self.timecodes[video.id] = timecodes
        let grabOperations = timecodes.map { timecode in
            let grabOperation = GrabOperation(video: video, timecode: timecode)
            grabOperation.completionBlock = {
                if let result = grabOperation.result {
                    switch result {
                    case .success(let success):
                        let imageURL = success
                        
                        DispatchQueue.main.async {
                            video.progress.current += 1
                        }
                        self.delegate?.progress(for: video, isCreated: video.progress.current, on: timecode, by: imageURL)
                    case .failure(let failure):
                        self.error = failure
                        self.delegate?.error(failure)
                    }
                }
                
                self.onNextOperation(for: video)
            }
            return grabOperation
        }
        return grabOperations
    }
    
    private func timecodes(for video: Video) -> [Timecode] {
        let shotsCount = video.progress.total //Int((video.duration / Double(period)).rounded(.down))
        var timecodes = [Timecode]()
        for shot in 0..<shotsCount {
            let timecode = Double(shot * period)
            timecodes.append(timecode)
        }
        return timecodes
    }
    
    private func onNextOperation(for video: Video) {
        if isGrabCompleteForCurrentVideo() {
            self.delegate?.completed(for: video)
            
            if self.isLastVideoFromSession(video: video) {
                self.delegate?.completedAll()
            } else {
                let nextVideoID = video.id + 1
                self.start(for: nextVideoID)
            }
        }
    }
    
    private func isGrabCompleteForCurrentVideo() -> Bool {
        return self.operationQueue.operationCount == .zero ? true : false
    }
    
    private func isLastVideoFromSession(video: Video) -> Bool {
        return video.id == videos.last?.id
    }
}
