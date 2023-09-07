//
//  RangeIntegerStrategy.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.09.2023.
//

import Foundation

struct RangeIntegerStrategy: ParseStrategy {
    func parse(_ value: String) throws -> Int {
        return Int(value) ?? 1
    }
}
