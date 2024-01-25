//
//  PlaybackStatus.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.01.2024.
//

import Foundation

enum PlaybackStatus {
    case loading
    case readyToPlay
    case caching
    case failed
    case unknown
    case status(_ status: String)
}

extension PlaybackStatus: CustomStringConvertible {
    var description: String {
        switch self {
        case .readyToPlay:
            return String(localized: "ready to play")
        case .caching:
            return String(localized: "caching...")
        case .failed:
            return String(localized: "failed")
        case .unknown:
            return String(localized: "unknown")
        case .status(let status):
            return status
        case .loading:
            return String(localized: "loading...")
        }
    }
}
