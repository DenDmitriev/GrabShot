//
//  PlaybackError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.01.2024.
//

import Foundation

enum PlaybackError: Error {
    case map(errorDescription: String?, failureReason: String?)
}

extension PlaybackError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .map(let errorDescription, _):
            return errorDescription
        }
    }
    var failureReason: String? {
        switch self {
        case .map(_ , let failureReason):
            return failureReason
        }
    }
}
