//
//  Grabber.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import Foundation

protocol GrabDelegate: AnyObject {
    func started(video: Video, progress: Int, total: Int)
    func didUpdate(video: Video, progress: Int, timecode: Duration, imageURL: URL)
    func didPause()
    func didResume()
    func canceled()
    func completed(video: Video, progress: Int)
    func hasError(_ error: LocalizedError)
}

class Grabber {
    typealias Timecode = TimeInterval
    
    var video: Video
    var period: Double
    weak var delegate: GrabDelegate?
    private var progress: Int = .zero
    private var totalProgress: Int?
    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    init(video: Video, period: Double, delegate: GrabDelegate?) {
        self.video = video
        self.period = period
        self.delegate = delegate
    }
    
    func start() {
        do {
            try startOperations(for: video)
        } catch let error {
            if let error = error as? LocalizedError {
                delegate?.hasError(error)
            }
        }
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
        delegate?.completed(video: video, progress: progress)
        delegate?.canceled()
    }
    
    func pause() {
        operationQueue.isSuspended = true
        delegate?.didPause()
    }
    
    func resume() {
        operationQueue.isSuspended = false
        delegate?.didResume()
    }
    
    private func startOperations(for video: Video) throws {
        guard let exportDirectory = video.exportDirectory
        else {
            delegate?.completed(video: video, progress: .zero)
            throw GrabError.exportDirectoryFailure(title: video.title)
        }
        
        guard FileManager.default.fileExists(atPath: exportDirectory.relativePath) 
        else {
            delegate?.completed(video: video, progress: .zero)
            throw GrabError.exportDirectoryFailure(title: video.title)
        }
        
        let operations = createOperations(for: video, with: period)
        
        totalProgress = operations.count
        progress = .zero
        
        operations.forEach { operation in
            operationQueue.addOperation(operation)
        }
        
        if let totalProgress {
            delegate?.started(video: video, progress: progress, total: totalProgress)
        }
    }
    
    private func createOperations(for video: Video, with period: Double) -> [GrabOperation] {
        let timecodes = timecodes(for: video)
        let grabOperations = timecodes.map { timecode in
            let grabOperation = GrabOperation(video: video, timecode: timecode, quality: UserDefaultsService.default.quality)
            grabOperation.completionBlock = { [weak self] in
                guard let self else { return }
                if let result = grabOperation.result {
                    switch result {
                    case .success(let success):
                        let imageURL = success
                        DispatchQueue.main.async {
                            video.images.append(imageURL)
                        }
                        self.progress += 1
                        self.delegate?.didUpdate(video: video, progress: progress, timecode: timecode, imageURL: imageURL)
                    case .failure(let failure):
                        if let error = failure as? LocalizedError {
                            self.delegate?.hasError(error)
                        }
                    }
                }
                
                if let totalProgress, self.progress >= totalProgress {
                    self.delegate?.completed(video: video, progress: totalProgress)
                }
            }
            return grabOperation
        }
        return grabOperations
    }
    
    private func timecodes(for video: Video) -> [Duration] {
        let shotsCount = video.progress.total
        var timecodes = [Duration]()
        
        for shot in 0..<shotsCount {
            let startTimecode: Duration
            switch video.range {
            case .full:
                startTimecode = video.timelineRange.lowerBound
            case .excerpt:
                startTimecode = video.rangeTimecode.lowerBound
            }
            let timecode = startTimecode + .seconds(Double(shot) * period)
            timecodes.append(timecode)
        }
        return timecodes
    }
}
