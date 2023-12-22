//
//  GrabShotError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.08.2023.
//

import Foundation

enum AppError: Error {
    case unknown
    case map(errorDescription: String?, recoverySuggestion: String?)
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        let comment = "Grab shot error"
        switch self {
        case .unknown:
            return NSLocalizedString("Unknown error", comment: comment)
        case .map(let errorDescription, _):
            return NSLocalizedString(errorDescription ?? "Unknown error", comment: comment)
        }
    }
    
    var recoverySuggestion: String? {
        let comment = "Grab shot error recovery suggestion"
        switch self {
        case .unknown:
            return NSLocalizedString("Unknown reaction", comment: comment)
        case .map(_, let recoverySuggestion):
            return NSLocalizedString(recoverySuggestion ?? "Unknown reaction", comment: comment)
        }
    }
}
