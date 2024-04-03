//
//  DropError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import Foundation

enum DropError: Error {
    case unknown
    case map(error: Error)
    case file(path: URL, allowedTypes: String)
}

extension DropError: LocalizedError {
    var errorDescription: String? {
        let comment = "Drop error description"
        switch self {
        case .unknown:
            return NSLocalizedString("Something went wrong", comment: comment)
        case .map(let error):
            return NSLocalizedString(error.localizedDescription, comment: comment)
        case .file(let path, _):
            return path.lastPathComponent + " " + NSLocalizedString("file type does not match the requirement", comment: comment)
        }
    }
    
    var recoverySuggestion: String? {
        let comment = "Drop error recovery suggestion"
        switch self {
        case .file(_, let allowedTypes):
            return NSLocalizedString("Use files with extension", comment: comment) + "\n" + allowedTypes
        case .unknown:
            return NSLocalizedString("Try again.", comment: comment)
        case .map(let error):
            if let error = error as? LocalizedError,
               let recoverySuggestion = error.recoverySuggestion {
                return NSLocalizedString(recoverySuggestion, comment: comment)
            } else {
                return NSLocalizedString("Try again.", comment: comment)
            }
        }
    }
}
