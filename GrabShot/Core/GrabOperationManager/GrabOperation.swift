//
//  GrabOperation.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.08.2023.
//

import Foundation

class GrabOperation: AsyncOperation {
    let video: Video
    let period: Double
    let timecode: Duration
    var durationOperation: TimeInterval = .zero
    var result: Result<URL, Error>?
    let quality: Double
    let format: FileService.Format
    
    init(video: Video, period: Double, timecode: Duration, quality: Double, format: FileService.Format) {
        self.video = video
        self.period = period
        self.timecode = timecode
        self.quality = quality
        self.format = format
        super.init()
    }
    
    override func main() {
        let startTime = Date()
        FFmpegVideoService.grab(in: video, period: period, timecode: timecode, quality: quality, format: format) { [weak self] result in
            self?.result = result
            self?.durationOperation = Date().timeIntervalSince(startTime)
            self?.state = .finished
        }
    }
}
