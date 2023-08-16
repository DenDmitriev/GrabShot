//
//  GrabShotError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.08.2023.
//

import Foundation

enum GrabShotError: Error {
    case map(errorDescription: String?, recoverySuggestion: String?)
}

extension GrabShotError: LocalizedError {
    var errorDescription: String? {
        let comment = "Grab shot error"
        switch self {
        case .map(let errorDescription, _):
            return NSLocalizedString(errorDescription ?? "Unknown error", comment: comment)
        }
    }
    
    var recoverySuggestion: String? {
        let comment = "Grab shot error recovery suggestion"
        switch self {
        case .map(_, let recoverySuggestion):
            return NSLocalizedString(recoverySuggestion ?? "Unknown reaction", comment: comment)
        }
    }
}
