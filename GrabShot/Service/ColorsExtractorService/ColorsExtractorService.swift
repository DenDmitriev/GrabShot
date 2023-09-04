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
    
    static func extract(from cgImage: CGImage, method: ColorExtractMethod, count: Int = 8, formula: DeltaEFormula = .CIE76, flags: [DominantColors.Flag] = []) throws -> [CGColor] {
        switch method {
        case .averageColor:
            let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .kMeansClustering)
            return colors
        case .averageAreaColor:
            let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .areaAverage(count: UInt8(count)))
            return colors
        case .dominationColor:
            let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .iterative(formula: formula), dominationColors: count, flags: flags)
            return colors
        }
    }
}
