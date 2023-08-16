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
    
    init(video: Video, timecode: TimeInterval) {
        self.video = video
        self.timecode = timecode
        super.init()
    }
    
    override func main() {
        let startTime = Date()
        VideoService.grab(in: video, timecode: timecode, quality: Session.shared.quality) { result in
            self.result = result
            self.durationOperation = Date().timeIntervalSince(startTime)
            self.state = .finished
        }
    }
}
