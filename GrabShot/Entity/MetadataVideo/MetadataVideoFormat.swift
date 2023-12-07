//
//  MetadataVideoFormat.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.12.2023.
//

import Foundation

extension MetadataVideo {
    struct Format: Codable, Identifiable, DictionaryKeyValueable {
        let id: UUID = UUID()
        let fileName: String?
        let numberStreams: Int?
        let formatName: String?
        let startTime: Duration?
        let duration: Duration?
        let size: Int?
        let bitRate: Int?
        let probeScore: Int?
        let tags: Tags?
        
        var dictionary: [CodingKeys: String?] {
            var dictionary = [CodingKeys: String?]()
            for key in CodingKeys.allCases {
                if let value = value(for: key) {
                    dictionary[key] = value
                }
            }
            return dictionary
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<MetadataVideo.Format.CodingKeys> = try decoder.container(keyedBy: MetadataVideo.Format.CodingKeys.self)
            self.fileName = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.CodingKeys.fileName)
            self.numberStreams = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Format.CodingKeys.numberStreams)
            self.formatName = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.CodingKeys.formatName)
            self.startTime = try MetadataVideo.decodeIfPresentDuration(container: container, key: .startTime)
            let durationString = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.CodingKeys.duration)
            self.duration = try MetadataVideo.decodeIfPresentDuration(container: container, key: .duration)
            self.size = try MetadataVideo.decodeIfPresentInt(container: container, key: .size)
            self.bitRate = try MetadataVideo.decodeIfPresentInt(container: container, key: .bitRate)
            self.probeScore = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Format.CodingKeys.probeScore)
            self.tags = try container.decodeIfPresent(MetadataVideo.Format.Tags.self, forKey: MetadataVideo.Format.CodingKeys.tags)
        }
        
        func value(for key: CodingKeys) -> String? {
            switch key {
            case .fileName:
                return fileName
            case .numberStreams:
                return numberStreams?.formatted()
            case .formatName:
                return formatName
            case .startTime:
                return startTime?.formatted(.time(pattern: .hourMinuteSecond))
            case .duration:
                return duration?.formatted(.time(pattern: .hourMinuteSecond))
            case .size:
                return MetadataVideo.fileSizeFormatted(value: size, unit: .byte, rule: .up)
            case .bitRate:
                return MetadataVideo.fileSizeFormatted(value: bitRate, unit: .bit, rule: .down)
            case .probeScore:
                return probeScore?.formatted()
            case .tags:
                return nil
            }
        }
        
        enum CodingKeys: String, CodingKey, CaseIterable, Keyable {
            case fileName = "filename"
            case numberStreams = "nb_streams"
            case formatName = "format_name"
            case startTime = "start_time"
            case duration = "duration"
            case size = "size"
            case bitRate = "bit_rate"
            case probeScore = "probe_score"
            case tags
            
            var id: String {
                self.rawValue
            }
            
            var index: Int {
                Self.allCases.firstIndex(of: self) ?? .zero
            }
            
            var description: String {
                switch self {
                case .fileName:
                    return "File name"
                case .numberStreams:
                    return "Number streams"
                case .formatName:
                    return "Format name"
                case .startTime:
                    return "Start time"
                case .duration:
                    return "Duration"
                case .size:
                    return "File size"
                case .bitRate:
                    return "Bit rate"
                case .probeScore:
                    return "Probe score"
                case .tags:
                    return "Tags"
                }
            }
        }
    }
}

extension MetadataVideo.Format {
    struct Tags: Codable, Identifiable, DictionaryKeyValueable {
        let id: UUID = UUID()
        let title: String?
        let encoder: String?
        let creationTime: Date?
        
        static let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            return dateFormatter
        }()
        
        var dictionary: [CodingKeys: String?] {
            var dictionary = [CodingKeys: String?]()
            for key in CodingKeys.allCases {
                if let value = value(for: key) {
                    dictionary[key] = value
                }
            }
            return dictionary
        }
        
        func value(for key: CodingKeys) -> String? {
            switch key {
            case .title:
                return title
            case .encoder:
                return encoder
            case .creationTime:
                if let creationTime {
                    return Self.dateFormatter.string(from: creationTime)
                } else {
                    return nil
                }
            }
        }
        
        enum CodingKeys: String, CodingKey, CaseIterable, Keyable {
            case title
            case encoder = "encoder"
            case creationTime = "creation_time"
            
            var id: String {
                self.rawValue
            }
            
            var index: Int {
                Self.allCases.firstIndex(of: self) ?? .zero
            }
            
            var description: String {
                switch self {
                case .title:
                    return "Title"
                case .encoder:
                    return "Encoder"
                case .creationTime:
                    return "Creation time"
                }
            }
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<MetadataVideo.Format.Tags.CodingKeys> = try decoder.container(keyedBy: MetadataVideo.Format.Tags.CodingKeys.self)
            self.title = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.Tags.CodingKeys.title)
            self.encoder = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.Tags.CodingKeys.encoder)
            if let creationTime = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.Tags.CodingKeys.creationTime) {
                let formatter = MetadataVideo.dateFormatterDecoder
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                self.creationTime = formatter.date(from: creationTime)
            } else {
                self.creationTime = nil
            }
        }
    }
}
