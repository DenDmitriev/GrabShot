//
//  GrabError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import Foundation

enum GrabError: Error {
    case unknown
    case map(errorDescription: String, recoverySuggestion: String?)
}

extension GrabError: LocalizedError {
    var errorDescription: String? {
        let comment = "Grab error"
        switch self {
        case .map(let errorDescription, _):
            return NSLocalizedString(errorDescription, comment: comment)
        case .unknown:
            return NSLocalizedString("Something went wrong", comment: comment)
        }
    }
    
    var recoverySuggestion: String? {
        let comment = "Grab error recovery suggestion"
        switch self {
        case .unknown:
            return NSLocalizedString("Try again", comment: comment)
        case .map(_, let recoverySuggestion):
            return NSLocalizedString(recoverySuggestion ?? "", comment: comment)
        }
    }
}