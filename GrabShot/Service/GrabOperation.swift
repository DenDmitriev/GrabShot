//
//  GrabOperation.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import SwiftUI

protocol GrabOperationDelegate: AnyObject {
    func start(videoID: Video.ID)
    func progress(for video: Video, progress: Progress)
    func complete(video: Video)
    func complete()
}

class GrabOperation {
    
    var videoService: VideoService
    var session: Session
    var operationQueue: OperationQueue
    var period: Int
    var timecodes: [ Int : [TimeInterval] ]
    
    weak var delegate: GrabOperationDelegate?
    
    init(_ videos: [Video], period: Int) {
        self.session = Session.shared
        self.videoService = VideoService()
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1 //serial operations in queue
        self.period = period
        self.timecodes = [:]
    }
    
    //MARK: - Public copntrol
    
    func start(for videoID: Int) {
        print(#function)
        guard let video = session.videos.first(where: { $0.id == videoID }) else { return }
        let operations = operations(for: video, with: period)
        operations.forEach { operation in
            operationQueue.addOperation(operation)
        }
        delegate?.start(videoID: videoID)
    }
    
    func cancel(completion: @escaping (() -> Void)) {
        print(#function)
        self.operationQueue.cancelAllOperations()
        completion()
    }
    
    //MARK: - Private
    
    private func timecodes(for video: Video) -> [TimeInterval] {
        let shotsCount = Int((video.duration / Double(period)).rounded(.down))
        return [Int] (0...shotsCount).map({ TimeInterval($0 * period) })
    }
    
    private func operations(for video: Video, with period: Int) -> [() -> ()] {
        let timecodes = timecodes(for: video)
        self.timecodes[video.id] = timecodes
        let operations = timecodes.map { timecode in
            return { self.grab(for: video, timecode: timecode) } //create closure operation
        }
        return operations
    }
    
    private func grab(for video: Video, timecode: TimeInterval) {
        print(#function)
        videoService.grab(in: video, timecode: timecode, quality: Session.shared.quality) { isGrabed, shotURL, error in
            if isGrabed {
                print("grabed for \(timecode)")
                
                //Progress update
                self.progress(for: video, timecode: timecode)
                
                //Поиск среднего цвета и добавление в массив
                self.averageColors(for: video, from: shotURL, count: self.session.stripCount)
                
                //Проверка на окончание операций по видео
                if self.isComplete() {
                    //next video grab
                    if video.id != Session.shared.videos.last?.id {
                        let nextVideoID = video.id + 1
                        self.start(for: nextVideoID)
                        self.delegate?.complete(video: video)
                        self.delegate?.start(videoID: nextVideoID)
                    } else {
                        self.delegate?.complete(video: video)
                        self.delegate?.complete()
                    }
                }
            } else {
                guard let error = error else { return }
                print(error.localizedDescription)
            }
        }
    }
    
    private func progress(for video: Video, timecode: TimeInterval) {
        guard
            let timecodes = self.timecodes[video.id],
            let currentShot = timecodes.firstIndex(of: timecode)
        else { return }
        
        let progress = Progress(current: (currentShot + 1), total: timecodes.count) // + 1 из-за массива от 0
        self.delegate?.progress(for: video, progress: progress)
    }
    
    //No useed
    private func averageColor(from shotURL: URL?) -> Color? {
        guard
            let imageURL = shotURL,
            let image = CIImage(contentsOf: imageURL)
        else { return nil }
        return image.averageColor
    }
    
    private func averageColors(for video: Video, from shotURL: URL?, count: Int) {
        guard
            let imageURL = shotURL,
            let image = CIImage(contentsOf: imageURL),
            let colors = image.averageColors(count: count)
        else { return }
        
        if video.colors == nil {
            video.colors = []
        }
        
        video.colors?.append(contentsOf: colors)
    }
    
    private func isComplete() -> Bool {
        return self.operationQueue.operationCount <= 1 ? true : false
    }
    
    private func nextGrab() {
        
    }
}
