//
//  GrabOperation.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.08.2023.
//

import Foundation

class GrabOperation: AsyncOperation {
    let video: Video
    let timecode: TimeInterval
    var durationOperation: TimeInterval = .zero
    var result: Result<URL, Error>?
    let quality: Double
    
    init(video: Video, timecode: TimeInterval, quality: Double) {
        self.video = video
        self.timecode = timecode
        self.quality = quality
        super.init()
    }
    
    override func main() {
        let startTime = Date()
        VideoService.grab(in: video, timecode: timecode, quality: quality) { [weak self] result in
            self?.result = result
            self?.durationOperation = Date().timeIntervalSince(startTime)
            self?.state = .finished
        }
    }
}
