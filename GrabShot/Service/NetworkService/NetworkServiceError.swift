//
//  NetworkServiceError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import Foundation

enum NetworkServiceError: Error {
    case map(error: Error)
    case invalidURL
    case invalidVideoId
    case videoNotFound
    case unknown
}

extension NetworkServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "Invalid url.", comment: "Error")
        case .videoNotFound:
            return String(localized: "Video not found.", comment: "Error")
        case .unknown:
            return String(localized: "Unknown error", comment: "Error")
        case .map(error: let error):
            return error.localizedDescription
        case .invalidVideoId:
            return String(localized: "Invalid video id", comment: "Error")
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidURL:
            return String(localized: "Use working link.", comment: "Error")
        case .videoNotFound:
            return String(localized: "Please, try again.", comment: "Error")
        case .unknown:
            return String(localized: "Unknown reason.", comment: "Error")
        case .map(error: let error):
            return (error as NSError).localizedFailureReason
        case .invalidVideoId:
            return String(localized: "Check the video link to ensure it is correct.", comment: "Error")
        }
    }
    
}
