//
//  StripModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2022.
//

import SwiftUI

struct ColorStrip: Identifiable, Hashable {
    let id: UUID
    let color: Color
    
    init(color: Color) {
        self.id = UUID()
        self.color = color
    }
}

class StripModel: ObservableObject {
    
    let video: Video
    
    init(video: Video) {
        self.video = video
    }
    
    func count() -> Int {
        video.colors.count
    }
}
