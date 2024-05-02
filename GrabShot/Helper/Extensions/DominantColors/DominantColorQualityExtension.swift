//
//  DominantColorQuality.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 02.05.2024.
//

import DominantColors

extension DominantColorQuality: CaseIterable, CustomStringConvertible, RawRepresentable {
    public init?(rawValue: Int) {
        self = Self.allCases[rawValue]
    }
    
    public var rawValue: Int {
        switch self {
        case .low:
            0
        case .fair:
            1
        case .high:
            2
        case .best:
            3
        }
    }
    
    public typealias RawValue = Int
    
    public static var allCases: [DominantColorQuality] {
        [.low, .fair, .high, .best]
    }
    
    public var description: String {
        switch self {
        case .low:
            "Low"
        case .fair:
            "Fair"
        case .high:
            "High"
        case .best:
            "Best"
        }
    }
}
