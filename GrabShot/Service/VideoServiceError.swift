//
//  VideoServiceError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.08.2023.
//

import Foundation

enum VideoServiceError: Error {
    case duration(video: Video)
}

extension VideoServiceError: LocalizedError {
    var errorDescription: String? {
        let comment = "Video service error"
        switch self {
        case .duration(let video):
            return NSLocalizedString("Can't get duration of video by path \(video.url)", comment: comment)
        }
    }
}
