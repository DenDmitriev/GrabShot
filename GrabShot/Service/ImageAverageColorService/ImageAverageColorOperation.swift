//
//  ImageAverageColorOperation.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import SwiftUI

class ImageAverageColorOperation: Operation {
    
    let nsImage: NSImage
    let colorCount: Int
    var result: [Color] = []
    
    init(nsImage: NSImage, colorCount: Int) {
        self.nsImage = nsImage
        self.colorCount = colorCount
    }
    
    override func main() {
        guard
            let data = nsImage.tiffRepresentation,
            let image = CIImage(data: data),
            let colors = image.averageColors(count: colorCount)
        else { return }
        
        result = colors
    }
}
