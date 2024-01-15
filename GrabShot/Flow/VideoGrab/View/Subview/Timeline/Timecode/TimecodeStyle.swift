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
        
        let frameRate: Double
        let separator: String
        
        public func format(_ value: Duration) -> String {
            let hours = Int(value.seconds / 3600)
            
            let minutes = Int(value.seconds / 60) % 60
            
            let seconds = Int(value.seconds) % 60
            
            let totalFrames = value.seconds * frameRate
            let frames = Int(Double(totalFrames).truncatingRemainder(dividingBy: frameRate))
            
            let timecode = [String(format: "%02d", hours), String(format: "%02d", minutes), String(format: "%02d", seconds), String(format: "%02d", frames)]
            
            return timecode.joined(separator: separator)
        }
    }
}

extension FormatStyle where Self == Duration.TimecodeStyle {

    /// A factory variable to create a timecode format style to format a duration.
    /// - Returns: A format style to format a duration.
    public static func timecode(frameRate: Double, separator: String = ":") -> Self { .init(frameRate: frameRate, separator: separator) }
}
