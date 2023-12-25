//
//  TimcodePickerError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 13.12.2023.
//

import Foundation

enum TimcodePickerError: LocalizedError {
    case unknown
    case map(errorDescription: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Error Description")
        case .map(errorDescription: let errorDescription):
            return errorDescription
        }
    }
}
