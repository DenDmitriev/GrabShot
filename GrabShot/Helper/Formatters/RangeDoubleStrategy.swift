//
//  RangeIntegerStrategy.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.09.2023.
//

import Foundation

struct RangeDoubleStrategy: ParseStrategy {
    func parse(_ value: String) throws -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        var separator: String = ","
        if let separatorComma = value.first(where: { $0 == "," }) {
            separator = String(separatorComma)
        } else if let separatorDot = value.first(where: { $0 == "." })  {
            separator = String(separatorDot)
        }
        formatter.decimalSeparator = separator
        
        let number = formatter.number(from: value)
        return number?.doubleValue ?? 1
    }
}
