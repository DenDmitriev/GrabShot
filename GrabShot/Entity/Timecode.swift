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
    var components: (hours: Int, minutes: Int, seconds: Int, frames: Int) {
        return (hours: hours, minutes: minutes, seconds: seconds, frames: frames)
    }
    
    var hours: Int {
        didSet {
            if hours >= 100 {
                hours = 99
            }
        }
    }
    var minutes: Int {
        willSet {
            if newValue >= 60 {
                let hours = newValue / 60
                self.hours += Int(hours)
            }
        }
        
        didSet {
            if minutes >= 60 {
                let partMinutes = (Double(minutes) / 60.0).truncatingRemainder(dividingBy: 1)
                minutes = Int(partMinutes * 60)
            }
        }
    }
    var seconds: Int {
        willSet {
            if newValue >= 60 {
                let minutes = newValue / 60
                self.minutes += Int(minutes)
            }
        }
        
        didSet {
            if seconds >= 60 {
                let partSecond = (Double(seconds) / 60.0).truncatingRemainder(dividingBy: 1)
                seconds = Int(partSecond * 60)
            }
        }
    }
    var frames: Int {
        willSet {
            if newValue >= Int(frameRate.value.rounded(.down)) {
                let seconds = Double(newValue) / frameRate.value
                self.seconds += Int(seconds)
            }
        }
        
        didSet {
            let maxFrame = Int(frameRate.value.rounded(.down))
            if frames >= maxFrame {
                let partSecond = (Double(frames) / Double(maxFrame)).truncatingRemainder(dividingBy: 1)
                frames = Int(partSecond * frameRate.value)
            }
        }
    }
    
    /// `String` with format - hh:mm:ss:fr
    var description: String {
        var result: String = ""
        result += Self.formatted(component: components.hours)
        result += ":"
        result += Self.formatted(component: components.minutes)
        result += ":"
        result += Self.formatted(component: components.seconds)
        result += ":"
        result += Self.formatted(component: components.frames)
        
        return result
    }
    
    /// Video frame rate for calculating frames
    var frameRate: FrameRate
    
    /// Total seconds
    var totalSeconds: Double {
        let hoursInSeconds = Double(components.hours * 60 * 60)
        let minutesInSeconds = Double(components.minutes * 60)
        let seconds = Double(components.seconds)
        let partSecond = Double(components.frames) / frameRate.value
        let result: Double = hoursInSeconds + minutesInSeconds + seconds + partSecond
        return result
    }
    
    enum FrameRate {
        case ntsc
        case pal
        case custom(value: Double)
        
        var value: Double {
            switch self {
            case .ntsc:
                return 29.97
            case .pal:
                return 25.0
            case .custom(let value):
                return value
            }
        }
    }
    
    init(hours: Int = .zero, minutes: Int = .zero, seconds: Int = .zero, frames: Int = .zero, frameRate: FrameRate) {
        let hoursChecked: Int = 0...23 ~= hours ? hours : .zero
        self.hours = hoursChecked
        
        let minutesChecked: Int = 0...59 ~= minutes ? minutes : .zero
        self.minutes = minutesChecked
        
        let secondsChecked: Int = 0...59 ~= seconds ? seconds : .zero
        self.seconds = secondsChecked
        
        let framesChecked: Int = 0...Int(frameRate.value.rounded(.down)) ~= frames ? frames : .zero
        self.frames = framesChecked
        
        self.frameRate = frameRate
        
    }
    
    // Initialization with format input hh:mm:ss:fr
    static func input(_ input: String, frameRate: FrameRate) -> Self {
        var inputComponents = input.split(separator: ":").compactMap({ Double($0) })
        var timecode = Timecode(frameRate: frameRate)
        
        guard 1...4 ~= inputComponents.count else { return timecode }
        
        let missingCount = 4 - inputComponents.count
        if missingCount > 0 {
            for _ in 1...missingCount {
                inputComponents.insert(.zero, at: 0)
            }
        }
        
        for index in 0...3 {
            switch index {
            case 0:
                let hours = inputComponents[0]
                timecode.hours = Int(hours)
            case 1:
                var minutes = inputComponents[1]
                timecode.minutes = Int(minutes)
            case 2:
                var seconds = inputComponents[2]
                timecode.seconds = Int(seconds)
            case 3:
                var frames = inputComponents[3]
                timecode.frames = Int(frames)
            default:
                break
            }
        }
        
        return timecode
    }
    
    /// Init with total seconds
    static func seconds<T>(_ seconds: T, with frameRate: FrameRate) -> Self where T : BinaryInteger {
        let secondsRounded = Duration.seconds(seconds).components.seconds
        let hours = secondsRounded / 3600
        let minutes = (secondsRounded / 60) % 60
        let seconds = secondsRounded % 60
        let frames = Double(seconds).truncatingRemainder(dividingBy: 1) * frameRate.value
        
        return Self.init(hours: Int(hours), minutes: Int(minutes), seconds: Int(seconds), frames: Int(frames), frameRate: frameRate)
    }
    
    static private func formatted(component: Int) -> String {
        if String(component).count <= 1 {
            return "0\(component)"
        } else {
            return "\(component)"
        }
    }
}
