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
    
    /// Окргуление с учетом кол-ва кадров в секунду
    func seconds(frameRate: Double) -> Double {
        let fractional = Double(components.attoseconds) / 1e18
        let frames = (fractional * frameRate).rounded()
        let fractionalFrames = frames / frameRate
        return Double(components.seconds) + fractionalFrames
    }
}

extension ClosedRange<Duration> {
    var timeInterval: TimeInterval {
        (self.upperBound - self.lowerBound).timeInterval
    }
    
    var duration: Duration {
        upperBound - lowerBound
    }
}
