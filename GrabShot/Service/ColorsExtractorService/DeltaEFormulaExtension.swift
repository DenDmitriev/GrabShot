//
//  DeltaEFormulaExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import DominantColors

extension DeltaEFormula {
    var name: String {
        switch self {
        case .euclidean:
            return "Euclidean"
        case .CIE76:
            return "CIE76"
        case .CIE94:
            return "CIE94"
        case .CIEDE2000:
            return "CIEDE2000"
        case .CMC:
            return "CMC"
        }
    }
}

extension DeltaEFormula: CustomStringConvertible {
    public var description: String {
        switch self {
        case .euclidean:
            return "It simply calculates the euclidean distance in the RGB color space."
        case .CIE76:
            return "The CIE76 algorithm is fast and yields acceptable results in most scenario."
        case .CIE94:
            return "The CIE94 algorithm is an improvement to the CIE76, especially for the saturated regions. It's marginally slower than CIE76."
        case .CIEDE2000:
            return "The CIEDE2000 algorithm is the most precise algorithm to compare colors. It is considerably slower than its predecessors."
        case .CMC:
            return "The CMC algorithm is defined a difference measure, based on the LHS (lightness, chroma, hue) color model."
        }
    }
}

