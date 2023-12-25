//
//  DurationFormatter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.08.2023.
//

import Foundation

class DurationFormatter {
    static let formatter = DateComponentsFormatter()
    
    static func string(_ duration: TimeInterval) -> String {
        formatter.string(from: duration) ?? "N/A"
    }
    
    static func stringWithUnits(_ duration: TimeInterval) -> String? {
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = [.default]
        return formatter.string(from: duration)
    }
}
