//
//  RangeIntegerStyle.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.09.2023.
//

import Foundation

struct RangeIntegerStyle: ParseableFormatStyle {
    var parseStrategy: RangeIntegerStrategy = .init()
    let range: ClosedRange<Int>
    
    func format(_ value: Int) -> String {
        let constrainedValue = min(max(value, range.lowerBound), range.upperBound)
        return "\(constrainedValue)"
    }
}
