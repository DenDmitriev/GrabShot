//
//  DurationExtansion.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 11.12.2023.
//

import Foundation

extension Duration {
    static func build(seconds: Double) -> Duration {
        let array = String(seconds).components(separatedBy: ".")
        
        let secondsString = array.first ?? "0"
        let attosecondsString = array.last ?? "0"
        let seconds = Int64(secondsString) ?? 0
        let attoseconds = Int64(attosecondsString) ?? 0
        
        let duration = Duration(secondsComponent: seconds, attosecondsComponent: attoseconds)
        return duration
    }
}
