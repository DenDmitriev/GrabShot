//
//  Timecode.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import Foundation

class Timecode: ObservableObject {
    
    @Published var hour: Int {
        didSet {
            if hour > maxHour {
                hour = oldValue
            }
            if hour == maxHour {
                if minute > maxMinute {
                    minute = maxMinute
                }
                if minute == maxMinute, second > maxSeconds {
                    second = maxSeconds
                }
            }
        }
    }
    
    @Published var minute: Int {
        didSet {
            if (hour * 60) + minute > maxHour * 60 + maxMinute {
                minute = oldValue
            }
            if hour == maxHour, minute == maxMinute {
                if second > maxSeconds {
                    second = maxSeconds
                }
            }
        }
    }
    
    @Published var second: Int {
        didSet {
            if (hour * 60 * 60) + (minute * 60 ) + second > Int(maxTimeInterval) {
                second = oldValue
            }
        }
    }
    
    var timeInterval: TimeInterval
    var maxTimeInterval: TimeInterval
    
    private var maxHour: Int { Int(maxTimeInterval) / 3600 }
    private var maxMinute: Int { (Int(maxTimeInterval) / 60) % 60 }
    private var maxSeconds: Int { Int(maxTimeInterval) % 60 }
    
    init(timeInterval: TimeInterval, maxTimeInterval: TimeInterval? = nil) {
        self.timeInterval = timeInterval
        
        if let maxTimeInterval = maxTimeInterval {
            self.maxTimeInterval = maxTimeInterval
        } else {
            self.maxTimeInterval = timeInterval
        }
        
        if timeInterval == .zero {
            hour = .zero
            minute = .zero
            second = .zero
        } else {
            let seconds = Int(timeInterval)
            hour = seconds / 3600
            minute = (seconds / 60) % 60
            second = seconds % 60
        }
    }
}
