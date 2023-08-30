//
//  ImageStripError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import Foundation

enum ImageStripError: Error {
    case unknown
    case map(errorDescription: String, recoverySuggestion: String?)
    case exportDirectory(title: String)
}

extension ImageStripError: LocalizedError {
    
    var errorDescription: String? {
        let comment = "Image strip error"
        switch self {
        case .unknown:
            return NSLocalizedString("Something went wrong", comment: comment)
        case .map(let errorDescription, _):
            return NSLocalizedString(errorDescription, comment: comment)
        case .exportDirectory(let title):
            return NSLocalizedString("No access for export folder", comment: comment) + title
        }
    }
    
    var recoverySuggestion: String? {
        let comment = "Image strip error recovery suggestion"
        switch self {
        case .unknown:
            return NSLocalizedString("Try again", comment: comment)
        case .map(_, let recoverySuggestion):
            return NSLocalizedString(recoverySuggestion ?? "", comment: comment)
        case .exportDirectory:
            return NSLocalizedString("Try again", comment: comment)
        }
    }
}
