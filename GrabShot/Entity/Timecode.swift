//
//  Timecode.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import Foundation

struct Timecode: CustomStringConvertible {
    
    /// Timecode components
    ///
    /// Format - hh:mm:ss:fr
    ///
    /// Example: 01:25:59:12 - 1 hour 25 minutes 59 seconds 12 frames
    ///
    var components: (hours: UInt8, minutes: UInt8, seconds: UInt8, frames: UInt8?)
    
    /// `String` with format - hh:mm:ss:fr
    var description: String {
        var result = "\(components.hours):\(components.minutes):\(components.seconds)"
        if frameRate != nil, let frames = components.frames {
            result += ":\(frames)"
        }
        return result
    }
    
    /// Video frame rate for calculating frames
    var frameRate: Double?
    
    /// Total seconds
    var seconds: Double {
        let hoursInSeconds = Double(components.hours * 60 * 60)
        let minutesInSeconds = Double(components.minutes * 60)
        let seconds = Double(components.seconds)
        var result: Double = hoursInSeconds + minutesInSeconds + seconds
        if let frameRate, let frames = components.frames {
            let partSecond = Double(frames) / frameRate
            result += partSecond
        }
        return result
    }
    
    init(hours: UInt8, minutes: UInt8, seconds: UInt8, frames: UInt8? = nil, frameRate: Double? = nil) {
        let hoursChecked: UInt8 = 0...23 ~= hours ? hours : .zero
        let minutesChecked: UInt8 = 0...59 ~= minutes ? minutes : .zero
        let secondsChecked: UInt8 = 0...59 ~= seconds ? seconds : .zero
        
        var components: (hours: UInt8, minutes: UInt8, seconds: UInt8, frames: UInt8?) = (hours: hoursChecked, minutes: minutesChecked, seconds: secondsChecked, frames: nil)
        
        if let frameRate, let frames {
            let framesChecked: UInt8 = 0...UInt8(frameRate.rounded(.down)) ~= frames ? frames : .zero
            components.frames = framesChecked
        }
        
        self.frameRate = frameRate
        self.components = components
        
    }
    
    /// Update hour component
    mutating func hours(_ hours: Int) {
        components.hours = UInt8(0...23 ~= hours ? hours : .zero)
    }
    
    /// Update minute component
    mutating func minutes(_ minutes: Int) {
        components.minutes = UInt8(0...59 ~= minutes ? minutes : .zero)
    }
    
    /// Update second component
    mutating func seconds(_ seconds: Int) {
        components.seconds = UInt8(0...59 ~= seconds ? seconds : .zero)
    }
    
    /// Update frame component
    mutating func frames(_ frames: Int, with frameRate: Double? = nil) {
        if let frameRate = frameRate {
            self.frameRate = frameRate
            components.frames = UInt8(
                0...Int(frameRate.rounded(.down)) ~= frames ? frames : .zero
            )
        } else if let frameRate = self.frameRate {
            components.frames = UInt8(
                0...Int(frameRate.rounded(.down)) ~= frames ? frames : .zero
            )
        }
    }
    
    /// Init with total seconds
    static func seconds<T>(_ seconds: T, with frameRate: Double? = nil) -> Self where T : BinaryInteger {
        let secondsRounded = Duration.seconds(seconds).components.seconds
        let hours = secondsRounded / 3600
        let minutes = (secondsRounded / 60) % 60
        let seconds = secondsRounded % 60
        var timecode = Self.init(hours: UInt8(hours), minutes: UInt8(minutes), seconds: UInt8(seconds))
        
        if let frameRate {
            timecode.frameRate = frameRate
            let attoseconds = Duration.seconds(seconds).components.attoseconds
            let frames = UInt8(Double(attoseconds / 1000000000000000000) * frameRate)
            // 1 секунда = 1 x 10+18 аттосекунда
            let framesChecked: UInt8 = 0...UInt8(frameRate.rounded(.down)) ~= frames ? frames : .zero
            timecode.components.frames = framesChecked
        }
        
        return timecode
    }
}
