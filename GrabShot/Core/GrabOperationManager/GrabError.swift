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
    case createStrip(localizedDescription: String)
    case access
    case exportDirectory(title: String)
}

extension GrabError: LocalizedError {
    var errorDescription: String? {
        let comment = "Grab error"
        switch self {
        case .map(let errorDescription, _):
            return NSLocalizedString(errorDescription, comment: comment)
        case .unknown:
            return NSLocalizedString("Something went wrong", comment: comment)
        case .createStrip(let localizedDescription):
            return localizedDescription
        case .access:
            return NSLocalizedString("Can't get write access to export folder", comment: comment)
        case .exportDirectory(let title):
            return NSLocalizedString("No export folder selected for ", comment: comment) + title
        }
    }
    
    var recoverySuggestion: String? {
        let comment = "Grab error recovery suggestion"
        switch self {
        case .unknown:
            return NSLocalizedString("Try again", comment: comment)
        case .map(_, let recoverySuggestion):
            return NSLocalizedString(recoverySuggestion ?? "", comment: comment)
        case .createStrip:
            return NSLocalizedString("Add write access for directory", comment: comment)
        case .access:
            return NSLocalizedString("Try restarting the app", comment: comment)
        case .exportDirectory:
            return NSLocalizedString("Remove the video from the list, then add it again and select the export folder", comment: comment)
        }
    }
}
