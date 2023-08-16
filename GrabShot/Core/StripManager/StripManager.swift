//
//  StripManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import Foundation
import CoreImage

class StripManager {
    
    var videos = [Video]()
    
    private var stripColorCount: Int
    
    init(stripColorCount: Int) {
        self.stripColorCount = stripColorCount
    }
    
    func appendAverageColors(for video: Video, from shotURL: URL?) {
        guard
            let imageURL = shotURL,
            let image = CIImage(contentsOf: imageURL),
            let colors = image.averageColors(count: stripColorCount)
        else { return }
        
        if video.colors == nil {
            video.colors = []
        }
        
        video.colors?.append(contentsOf: colors)
    }
}
