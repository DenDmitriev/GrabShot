//
//  StripColorManagerError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import Foundation

enum StripColorManagerError: Error {
    case imageFailure(url: URL)
}

extension StripColorManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .imageFailure(let url):
            return String(localized: "The image \(url.lastPathComponent) is corrupted or does not exist.")
        }
    }
    
    var failureReason: String? {
        switch self {
        case .imageFailure(let url):
            return String(localized: "Check the image URL \(url.relativePath).")
        }
    }
}
