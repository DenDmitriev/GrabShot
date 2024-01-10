//
//  DurationExtansion.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 11.12.2023.
//

import Foundation

extension Duration {
    var timeInterval: TimeInterval {
        let seconds = Double(components.seconds)
        let partSecond = Double(components.attoseconds) / 1e18
        return seconds + partSecond
    }
    
    var seconds: Double {
        return timeInterval
    }
}

extension ClosedRange<Duration> {
    var timeInterval: TimeInterval {
        (self.upperBound - self.lowerBound).timeInterval
    }
}
