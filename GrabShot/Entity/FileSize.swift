//
//  FileSize.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2023.
//

import Foundation

struct FileSize {
    var size: Double
    let unit: Unit
    
    init(size: Double, unit: Unit) {
        self.size = size
        self.unit = unit
    }
    
    init(size: Int, unit: Unit) {
        let sizeDouble = Double(size)
        self.size = sizeDouble
        self.unit = unit
    }
    
    func size(in unit: Unit) -> Double {
        return size * Double(self.unit.factor) / Double(unit.factor)
    }
    
    func optimal(rule: FloatingPointRoundingRule? = nil) -> Self {
        let sizeInKiloBytes = size * self.unit.factor / 1000
        let optimal: Self
        switch sizeInKiloBytes {
        case 0..<1:
            optimal = .init(size: size(in: .bit), unit: .bit)
        case 1..<1000:
            if rule == .up {
                fallthrough
            } else {
                optimal = .init(size: size(in: .byte), unit: .byte)
            }
        case 1..<1000:
            optimal = .init(size: size(in: .kiloByte), unit: .kiloByte)
        case 1000..<1000000:
            if rule == .up {
                fallthrough
            } else {
                optimal = .init(size: size(in: .kiloByte), unit: .kiloByte)
            }
        case 1000..<1000000:
            optimal = .init(size: size(in: .megaByte), unit: .megaByte)
        case 1000000...:
            if rule == .up {
                fallthrough
            } else {
                optimal = .init(size: size(in: .megaByte), unit: .megaByte)
            }
        case 1000000..<1000000000:
            if rule == .up {
                fallthrough
            } else {
                optimal = .init(size: size(in: .megaByte), unit: .megaByte)
            }
        case 1000000000...:
            optimal = .init(size: size(in: .gigaByte), unit: .gigaByte)
        default:
            return self
        }
        return optimal
    }
}

extension FileSize {
    enum Unit {
        case bit
        case byte
        case kiloByte
        case megaByte
        case gigaByte
        
        var factor: Double {
            switch self {
            case .bit:
                return 1/8
            case .byte:
                return 1
            case .kiloByte:
                return 1000
            case .megaByte:
                return 1000000
            case .gigaByte:
                return 1000000000
            }
        }
        
        var designation: String {
            switch self {
            case .bit:
                return "bit"
            case .byte:
                return "B"
            case .kiloByte:
                return "KB"
            case .megaByte:
                return "MB"
            case .gigaByte:
                return "GB"
            }
        }
    }
}

extension FileSize: CustomStringConvertible {
    var description: String {
        return Int(size.rounded()).formatted() + " " + self.unit.designation
    }
    
    func formatted() -> String {
        return description
    }
}
