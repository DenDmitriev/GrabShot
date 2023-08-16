//
//  DurationFormatter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.08.2023.
//

import Foundation

class DurationFormatter {
    static func string(_ duration: TimeInterval) -> String {
        DateComponentsFormatter().string(from: duration) ?? "N/A"
    }
    
    static func stringWithUnits(_ duration: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = [.default]
        return formatter.string(from: duration)
    }
}
