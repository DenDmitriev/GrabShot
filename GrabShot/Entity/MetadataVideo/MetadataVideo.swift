//
//  MetadataVideo.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.12.2023.
//

import Foundation

protocol Keyable: Identifiable, CustomStringConvertible, Hashable {
    var index: Int { get }
}

protocol DictionaryKeyValueable {
    associatedtype Key: CodingKey, CaseIterable, Keyable
    var dictionary: [Key: String?] { get }
    func value(for key: Key) -> String?
}

struct MetadataVideo: Codable {
    let streams: [Stream]
    let format: Format
}

extension MetadataVideo: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(format.fileName)
    }
    
    static func == (lhs: MetadataVideo, rhs: MetadataVideo) -> Bool {
        lhs.format.fileName == rhs.format.fileName
    }
}

extension MetadataVideo {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    static let dateFormatterDecoder: DateFormatter = {
        let formatter = Self.dateFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    static func duration(seconds: Double) -> Duration? {
        let array = String(seconds).components(separatedBy: ".")
        guard 1...2 ~= array.count else { return nil }
        
        let secondsString = array.first ?? "0"
        let attosecondsString = array.last ?? "0"
        let seconds = Int64(secondsString) ?? 0
        let attoseconds = Int64(attosecondsString) ?? 0
        
        let duration = Duration(secondsComponent: seconds, attosecondsComponent: attoseconds)
        return duration
    }
    
    static func fileSize(value: Int, unit: FileSize.Unit) -> FileSize {
        let fileSize = FileSize(size: value, unit: unit)
        return fileSize
    }
    
    static func decodeIfPresentDuration<Key: CodingKey>(container: KeyedDecodingContainer<Key>, key: Key) throws -> Duration? {
        if let string = try container.decodeIfPresent(String.self, forKey: key),
           let double = Double(string),
           let duration = MetadataVideo.duration(seconds: double) {
            return duration
        } else {
            return nil
        }
    }
    
    static func decodeIfPresentInt<Key: CodingKey>(container: KeyedDecodingContainer<Key>, key: Key) throws -> Int? {
        if let string = try container.decodeIfPresent(String.self, forKey: key),
           let int = Int(string) {
            return int
        } else {
            return nil
        }
    }
    
    static func fileSizeFormatted(value: Int?, unit: FileSize.Unit, rule: FloatingPointRoundingRule? = nil) -> String? {
        if let value {
            let fileSize = MetadataVideo.fileSize(value: value, unit: unit)
            return fileSize.optimal(rule: rule).formatted()
        } else {
            return nil
        }
    }
}

extension MetadataVideo {
    static let placeholder: Self? = {
        let url = Bundle.main.url(forResource: "metadata", withExtension: "json")
        guard let url else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let metadata = try JSONDecoder().decode(MetadataVideo.self, from: data)
            return metadata
        } catch {
            return nil
        }
    }()
}
