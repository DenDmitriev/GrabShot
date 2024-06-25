//
//  ColorMood.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import Foundation
import DominantColors

class ColorMood: ObservableObject {
    
    @Published var formula: DeltaEFormula
    @Published var method: ColorExtractMethod
    @Published var quality: DominantColorQuality
    @Published var isExcludeWhite: Bool
    @Published var isExcludeBlack: Bool
    @Published var isExcludeGray: Bool
    
    var options: [DominantColors.Options] {
        var options = [DominantColors.Options]()
        if isExcludeBlack {
            options.append(.excludeBlack)
        }
        if isExcludeWhite {
            options.append(.excludeWhite)
        }
        if isExcludeGray {
            options.append(.excludeGray)
        }
        return options
    }
    
    init(method: ColorExtractMethod? = nil, formula: DeltaEFormula? = nil, quality: DominantColorQuality? = nil, isExcludeBlack: Bool? = nil, isExcludeWhite: Bool? = nil, isExcludeGray: Bool? = nil) {
        let userDefaultsService = UserDefaultsService.default
        self.method = method ?? userDefaultsService.colorExtractMethod
        self.formula = formula ?? userDefaultsService.colorDominantFormula
        self.isExcludeBlack = isExcludeBlack ?? userDefaultsService.isExcludeBlack
        self.isExcludeWhite = isExcludeWhite ?? userDefaultsService.isExcludeWhite
        self.isExcludeGray = isExcludeGray ?? userDefaultsService.isExcludeGray
        self.quality = quality ?? userDefaultsService.dominantColorsQuality
    }
}
