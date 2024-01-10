//
//  DoubleRoundExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import Foundation

extension Double {
    /// Округление после `places` цифры после запятой
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CGFloat {
    /// Округление после `places` цифры после запятой
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
