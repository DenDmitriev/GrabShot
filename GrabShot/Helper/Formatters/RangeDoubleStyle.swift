//
//  RangeIntegerStyle.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.09.2023.
//

import Foundation

struct RangeDoubleStyle: ParseableFormatStyle {
    var parseStrategy: RangeDoubleStrategy = .init()
    let range: ClosedRange<Double>
    
    func format(_ value: Double) -> String {
        let constrainedValue = min(max(value, range.lowerBound), range.upperBound)
            .round(to: 2)
        
        return constrainedValue.formatted(.number)
    }
}
