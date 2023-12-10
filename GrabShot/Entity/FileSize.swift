//
//  FileSize.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2023.
//

import Foundation

struct FileSize {
    var size: Double
    var unit: Unit
    
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
        let bytes = size * self.unit.factor
        let optimal: Self
        
        switch rule {
        case .down:
            switch bytes {
            case 0..<10:
                optimal = .init(size: size(in: .bit), unit: .bit)
            case 10..<10000:
                optimal = .init(size: size(in: .byte), unit: .byte)
            case 10000..<10000000:
                optimal = .init(size: size(in: .kiloByte), unit: .kiloByte)
            case 10000000..<10000000000:
                optimal = .init(size: size(in: .megaByte), unit: .megaByte)
            case 10000000000..<10000000000000:
                optimal = .init(size: size(in: .gigaByte), unit: .gigaByte)
            case 10000000000000...:
                optimal = .init(size: size(in: .teraByte), unit: .teraByte)
            default:
                return self
            }
        case .up:
            switch bytes {
            case 0..<0.1:
                optimal = .init(size: size(in: .bit), unit: .bit)
            case 0.1..<100:
                optimal = .init(size: size(in: .byte), unit: .byte)
            case 100..<100000:
                optimal = .init(size: size(in: .kiloByte), unit: .kiloByte)
            case 100000..<100000000:
                optimal = .init(size: size(in: .megaByte), unit: .megaByte)
            case 100000000..<100000000000:
                optimal = .init(size: size(in: .gigaByte), unit: .gigaByte)
            case 100000000000...:
                optimal = .init(size: size(in: .teraByte), unit: .teraByte)
            default:
                return self
            }
        default:
            switch bytes {
            case 0..<1:
                optimal = .init(size: size(in: .bit), unit: .bit)
            case 1..<1000:
                optimal = .init(size: size(in: .byte), unit: .byte)
            case 1000..<1000000:
                optimal = .init(size: size(in: .kiloByte), unit: .kiloByte)
            case 1000000..<1000000000:
                optimal = .init(size: size(in: .megaByte), unit: .megaByte)
            case 1000000000..<1000000000000:
                optimal = .init(size: size(in: .gigaByte), unit: .gigaByte)
            case 1000000000000...:
                optimal = .init(size: size(in: .teraByte), unit: .teraByte)
            default:
                return self
            }
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
        case teraByte
        
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
            case .teraByte:
                return 1000000000000
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
            case .teraByte:
                return "TB"
            }
        }
    }
}

extension FileSize: CustomStringConvertible {
    var description: String {
        return Int(size.rounded()).formatted() + " " + self.unit.designation
    }
}

extension FileSize {

    /// Format `self` using `IntegerFormatStyle()`
    public func formatted() -> String {
        self.description
    }

    /// Format `self` with the given format.
    public func formatted<S>(_ format: S) -> S.FormatOutput where Self == S.FormatInput, S : FormatStyle {
        format.format(self)
    }
}

struct FileSizeFormatStyle: FormatStyle {
    /// Creates a `String` instance from `FileSize`.
    func format(_ value: FileSize) -> String {
        return value.size.formatted() + " " + value.unit.designation
    }
}

extension FormatStyle where Self == FileSizeFormatStyle {
    static var fileSize: FileSizeFormatStyle { .init() }
}
