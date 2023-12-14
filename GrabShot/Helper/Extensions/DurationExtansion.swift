//
//  DurationExtansion.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 11.12.2023.
//

import Foundation

extension Duration {
    var timeInterval: TimeInterval {
        return Double("\(self.components.seconds).\(self.components.attoseconds)") ?? .zero
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
