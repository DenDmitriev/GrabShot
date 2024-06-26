//
//  AnalyticsEvent.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.06.2024.
//

import Foundation

enum AnalyticsEvent: String {
    case importVideo, importYoutubeVideo, importVimeoVideo
    case grabFinish, cutVideoFinish
    case exportImageStrip
    
    var key: String {
        self.toSnakeCase() ?? self.rawValue
    }
    
    private func toSnakeCase() -> String? {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.rawValue.count)
        return regex?.stringByReplacingMatches(in: self.rawValue, options: [], range: range, withTemplate: "$1_$2").lowercased()
    }
}
