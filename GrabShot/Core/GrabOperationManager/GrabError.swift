//
//  GrabError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import Foundation

enum GrabError: Error {
    case unknown
    case map(errorDescription: String, failureReason: String?)
    case createStrip(localizedDescription: String)
    case accessFailure
    case exportDirectoryFailure(title: String)
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
        case .accessFailure:
            return NSLocalizedString("Can't get write access to export folder", comment: comment)
        case .exportDirectoryFailure(let title):
            return NSLocalizedString("No export folder selected for ", comment: comment) + title
        }
    }
    
    var failureReason: String? {
        let comment = "Grab error failure reason"
        switch self {
        case .unknown:
            return NSLocalizedString("Try again.", comment: comment)
        case .map(_, let failureReason):
            return NSLocalizedString(failureReason ?? "", comment: comment)
        case .createStrip:
            return NSLocalizedString("Add write access for directory.", comment: comment)
        case .accessFailure:
            return NSLocalizedString("Try restarting the app.", comment: comment)
        case .exportDirectoryFailure:
            return NSLocalizedString("Please select an export folder.", comment: comment)
        }
    }
}
