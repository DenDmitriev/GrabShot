//
//  Histogram.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import Foundation
import Accelerate

struct Histogram {
    let red: [vImagePixelCount]
    let green: [vImagePixelCount]
    let blue: [vImagePixelCount]
    let alpha: [vImagePixelCount]
    let range: [vImagePixelCount]
    
    init(red: [vImagePixelCount], green: [vImagePixelCount], blue: [vImagePixelCount], alpha: [vImagePixelCount]) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        var range = [vImagePixelCount](repeating: 0, count: 256)
        (0...255).forEach { index in
            range[index] = red[index] + green[index] + blue[index]
        }
        self.range = range
    }
}
