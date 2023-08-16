//
//  Status.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2022.
//

import SwiftUI

enum GrabState: RawRepresentable {
    case ready
    case calculating
    case grabbing(log: String)
    case pause(log: String? = nil)
    case canceled
    case complete(shots: Int)
    
    typealias RawValue = String
    
    init?(rawValue: String) {
        return nil
    }
    
    var rawValue: RawValue {
        switch self {
        case .ready:
            return "Ready"
        case .calculating:
            return "Calculating"
        case .grabbing:
            return "Grabbing..."
        case .pause:
            return "Pause"
        case .canceled:
            return "Canceled"
        case .complete:
            return "Complete"
        }
    }
    
    func localizedString() -> String {
        let comment = "Sates operations"
        return NSLocalizedString(self.rawValue, comment: comment)
    }
}

extension GrabState: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension GrabState: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension GrabState {
    
    var description: String {
        let comment = "Grabbing states"
        switch self {
        case .grabbing(let log):
            return NSLocalizedString(log, comment: comment)
        case .pause(let log):
            return log ?? " "
        case .complete(let shots):
            return "\(shots) " + NSLocalizedString("shots grabbed", comment: comment)
        default:
            return " "
        }
    }
}
