//
//  VideoServiceError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.08.2023.
//

import Foundation

enum VideoServiceError: Error {
    case duration(video: Video)
    case grab(video: Video, timecode: Duration)
    case exportDirectory
    case alreadyExists(name: String, path: String)
    case cacheDirectory
    case commandFailure
    case parsingMetadataFailure
    case createCacheVideoFailure
    case error(errorDescription: String, recoverySuggestion: String?)
}

extension VideoServiceError: LocalizedError {
    var errorDescription: String? {
        let comment = "Video service error"
        switch self {
        case .duration(let video):
            return NSLocalizedString("Can't get duration of video by path", comment: comment) + ": " + "\(video.url.relativePath)"
        case .grab(let video, let timecode):
            let stringTimecode = timecode.formatted(.time(pattern: .hourMinuteSecond))
            return NSLocalizedString("Can't grab shot in", comment: comment) + " " + "\(stringTimecode)" + " " + "\(video.title)"
        case .exportDirectory:
            return NSLocalizedString("Can't get export directory", comment: comment)
        case .alreadyExists(let name, let path):
            let string = String(format: "%@ already exists on path %@", name, path)
            return string
        case .cacheDirectory:
            return NSLocalizedString("Error getting cache directory path", comment: comment)
        case .commandFailure:
            return NSLocalizedString("Command error", comment: comment)
        case .parsingMetadataFailure:
            return NSLocalizedString("Cannot decode metadata", comment: comment)
        case .createCacheVideoFailure:
            return NSLocalizedString("Unable to create cache for video", comment: comment)
        case .error(errorDescription: let message, _):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        let comment = "Video service error"
        switch self {
        case .duration:
            return NSLocalizedString("Use another file.", comment: comment)
        case .grab:
            return NSLocalizedString("Try restarting the application and try again.", comment: comment)
        case .exportDirectory:
            return NSLocalizedString("Select the destination folder again.", comment: comment)
        case .alreadyExists(let name, let path):
            return NSLocalizedString("Delete the existing file \(name) by path \(path) and start the process again.", comment: comment)
        case .cacheDirectory:
            return NSLocalizedString("Try restarting the application and try again.", comment: comment)
        case .commandFailure:
            return NSLocalizedString("Try updating the application.", comment: comment)
        case .parsingMetadataFailure:
            return NSLocalizedString("This file is corrupted or not supported.", comment: comment)
        case .createCacheVideoFailure:
            return NSLocalizedString("This file is corrupted or not supported", comment: comment)
        case .error(_, let recoverySuggestion):
            return recoverySuggestion
        }
    }
}
