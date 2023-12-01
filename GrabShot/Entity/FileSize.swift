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
    
    func size(in unit: Unit) -> Double {
        return size * Double(self.unit.factor) / Double(unit.factor)
    }
    
    func optimal() -> Self {
        let sizeInKiloBytes = size * Double(self.unit.factor)
        let optimal: Self
        switch sizeInKiloBytes {
        case 0..<1000:
            optimal = .init(size: size(in: .byte), unit: .byte)
        case 1000..<1000000:
            optimal = .init(size: size(in: .kiloByte), unit: .kiloByte)
        case 1000000...:
            optimal = .init(size: size(in: .megaByte), unit: .megaByte)
        default:
            return self
        }
        
        return optimal
    }
}

extension FileSize {
    enum Unit {
        case byte
        case kiloByte
        case megaByte
        
        var factor: Int {
            switch self {
            case .byte:
                return 1
            case .kiloByte:
                return 1000
            case .megaByte:
                return 1000000
            }
        }
        
        var designation: String {
            switch self {
            case .byte:
                return "B"
            case .kiloByte:
                return "KB"
            case .megaByte:
                return "MB"
            }
        }
    }
}

extension FileSize: CustomStringConvertible {
    var description: String {
        return Int(size.rounded()).formatted() + " " + self.unit.designation
    }
}
