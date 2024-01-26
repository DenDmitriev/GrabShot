//
//  TimecodeStyle.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//
// Теория
// https://en.editingtools.io/timecode/
// https://stackoverflow.com/questions/31149502/display-timecode-for-video-track-using-swift-avplayer

import Foundation

extension Duration {
    public struct TimecodeStyle: FormatStyle {
        public typealias FormatInput = Duration
        public typealias FormatOutput = String
        
        let frameRate: Double
        let separator: String
        
        public func format(_ value: Duration) -> String {
            var frames = value.seconds * frameRate
            
            let hours = (frames / (3600 * frameRate)).rounded(.down)
            
            frames -= (hours * (3600 * frameRate))
            
            let minutes = (frames / (60 * frameRate)).rounded(.down)
            
            frames -= minutes * (60 * frameRate)
            
            let seconds = (frames / frameRate).round(to: 3).rounded(.down)
            
            frames -= seconds * frameRate
            
            let timecode = [
                String(format: "%02d", Int(hours)),
                String(format: "%02d", Int(minutes)),
                String(format: "%02d", Int(seconds)),
                String(format: "%02d", Int(frames))
            ]
            
            return timecode.joined(separator: separator)
        }
    }
}

extension FormatStyle where Self == Duration.TimecodeStyle {

    /// A factory variable to create a timecode format style to format a duration.
    /// - Returns: A format style to format a duration.
    public static func timecode(frameRate: Double, separator: String = ":") -> Self { .init(frameRate: frameRate, separator: separator) }
}
