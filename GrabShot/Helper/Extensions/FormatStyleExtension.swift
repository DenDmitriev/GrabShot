//
//  FormatStyleExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.09.2023.
//

import Foundation

/// Allow writing `.ranged(0...5)` instead of `RangeIntegerStyle(range: 0...5)`.
extension FormatStyle where Self == RangeIntegerStyle {
    static func ranged(_ range: ClosedRange<Int>) -> RangeIntegerStyle {
        return RangeIntegerStyle(range: range)
    }
}
