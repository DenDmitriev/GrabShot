//
//  StripManagerImage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class StripManagerImage {
    
    static func getAverageColors(nsImage: NSImage, colorCount: Int) -> [Color]? {
        guard
            let data = nsImage.tiffRepresentation,
            let image = CIImage(data: data),
            let colors = image.averageColors(count: colorCount)
        else { return nil }
        
        return colors
    }
}
