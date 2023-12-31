//
//  VideoServiceError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.08.2023.
//

import Foundation

enum VideoServiceError: Error {
    case duration(video: Video)
    case grab(video: Video, timecode: TimeInterval)
    case exportDirectory
}

extension VideoServiceError: LocalizedError {
    var errorDescription: String? {
        let comment = "Video service error"
        switch self {
        case .duration(let video):
            return NSLocalizedString("Can't get duration of video by path", comment: comment) + ": " + "\(video.url.relativePath)"
        case .grab(let video, let timecode):
            let stringTimecode = DurationFormatter.string(timecode)
            return NSLocalizedString("Can't grab shot in", comment: comment) + " " + "\(stringTimecode)" + " " + "\(video.title)"
        case .exportDirectory:
            return NSLocalizedString("Can't get export directory", comment: comment)
        }
    }
}
