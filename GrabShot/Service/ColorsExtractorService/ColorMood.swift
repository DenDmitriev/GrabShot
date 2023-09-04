//
//  ColorMood.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import Foundation
import DominantColors

/// Предустановка цветового отделения по различным сценариям
enum ColorMood {
    case averageColor
    case averageAreaColor
    case dominationColor(formula: DeltaEFormula)
}

extension ColorMood: CustomStringConvertible {
    var description: String {
        switch self {
        case .averageColor:
            return "Finds the dominant colors of an image by using using a k-means clustering algorithm."
        case .averageAreaColor:
            return "Finds the dominant colors of an image by using using a area average algorithm."
        case .dominationColor(formula: let formula):
            return "Finds the dominant colors of an image by iterating, grouping and sorting its pixels and using a \(formula.name)."
        }
    }
}
