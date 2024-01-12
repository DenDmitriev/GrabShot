//
//  TimecodeStyle.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import Foundation

extension Duration {
    public struct TimecodeStyle: FormatStyle {
        public typealias FormatInput = Duration
        public typealias FormatOutput = String
        
        var frameRate: Double
        
        public func format(_ value: Duration) -> String {
            let hours = Int(value.seconds / 3600)
            let hoursFormatted = Self.formatted(component: hours)
            
            let minutes = Int(value.seconds / 60) % 60
            let minutesFormatted = Self.formatted(component: minutes)
            
            let seconds = Int(value.seconds) % 60
            let secondsFormatted = Self.formatted(component: seconds)
            
            let frames = Int(value.seconds.truncatingRemainder(dividingBy: 1).round(to: 2) * frameRate)
            let framesFormatted = Self.formatted(component: frames)
            
            return "\(hoursFormatted):\(minutesFormatted):\(secondsFormatted):\(framesFormatted)"
        }
        
        /// Add zero if timecode component less 10
        static private func formatted(component: Int) -> String {
            if String(component).count <= 1 {
                return "0\(component)"
            } else {
                return "\(component)"
            }
        }
    }
}

extension FormatStyle where Self == Duration.TimecodeStyle {

    /// A factory variable to create a timecode format style to format a duration.
    /// - Returns: A format style to format a duration.
    public static func timecode(frameRate: Double) -> Self { .init(frameRate: frameRate) }
}
