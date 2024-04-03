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
    @Published var isExcludeWhite: Bool
    @Published var isExcludeBlack: Bool
    
    var flags: [DominantColors.Flag] {
        var flags = [DominantColors.Flag]()
        if isExcludeBlack {
            flags.append(.excludeBlack)
        }
        if isExcludeWhite {
            flags.append(.excludeWhite)
        }
        return flags
    }
    
    init(method: ColorExtractMethod? = nil, formula: DeltaEFormula? = nil, isExcludeBlack: Bool? = nil, isExcludeWhite: Bool? = nil) {
        let userDefaultsService = UserDefaultsService.default
        self.method = method ?? userDefaultsService.colorExtractMethod
        self.formula = formula ?? userDefaultsService.colorDominantFormula
        self.isExcludeBlack = isExcludeBlack ?? userDefaultsService.isExcludeBlack
        self.isExcludeWhite = isExcludeWhite ?? userDefaultsService.isExcludeWhite
    }
}
