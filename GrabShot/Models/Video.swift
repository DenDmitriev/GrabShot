//
//  Video.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI

class Video: Identifiable, Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.url == rhs.url
    }
    
    var id: Int
    var title: String
    var url: URL
    var duration: TimeInterval
    var durationString: String
    var shots: Int
    var progress = 0.0
    
    var colors: [Color]?
    
    init(url: URL) {
        self.id = Session.shared.videos.count   //+ 1
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
        self.duration = 0.0
        self.shots = 0
        self.durationString = "N/A"
    }
    
    enum Value {
        case duration, shots, all
    }
}
