//
//  VideoGrabState.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import Foundation

enum VideoGrabState {
    case ready
    case calculating
    case grabbing
    case pause
    case canceled
    case complete(shots: Int)
    
    var description: String {
        let comment = "Grab state description"
        switch self {
        case .ready:
            return NSLocalizedString("Ready", comment: comment)
        case .calculating:
            return NSLocalizedString("Calculating", comment: comment)
        case .grabbing:
            return NSLocalizedString("Grabbing...", comment: comment)
        case .pause:
            return NSLocalizedString("Pause", comment: comment)
        case .canceled:
            return NSLocalizedString("Canceled", comment: comment)
        case .complete:
            return NSLocalizedString("Complete", comment: comment)
        }
    }
}
