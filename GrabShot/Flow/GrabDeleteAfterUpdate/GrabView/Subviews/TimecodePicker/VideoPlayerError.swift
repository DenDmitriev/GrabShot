//
//  TimcodePickerError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 13.12.2023.
//

import Foundation

enum VideoPlayerError: LocalizedError {
    case unknown
    case map(errorDescription: String, failureReason: String?)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Error Description")
        case .map(let errorDescription, _):
            return errorDescription
        }
    }
    
    var failureReason: String? {
        switch self {
        case .unknown:
            return nil
        case .map(_, let failureReason):
            return failureReason
        }
    }
}
