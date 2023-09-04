//
//  class AverageColorsService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import Foundation
import CoreImage
import DominantColors

class ColorsExtractorService {
    
    static func extract(from cgImage: CGImage, mood: ColorMood, count: Int) throws -> [CGColor] {
        switch mood {
        case .averageColor:
            let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .kMeansClustering)
            return colors
        case .averageAreaColor:
            let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .areaAverage(count: UInt8(count)))
            return colors
        case .dominationColor(formula: let formula):
            let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .iterative(formula: formula))
            return colors
        }
    }
}
