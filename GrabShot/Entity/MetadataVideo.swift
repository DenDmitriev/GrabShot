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

extension MetadataVideo: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(format.fileName)
    }
    
    static func == (lhs: MetadataVideo, rhs: MetadataVideo) -> Bool {
        lhs.format.fileName == rhs.format.fileName
    }
}

extension MetadataVideo {
    enum CodecType: String, Codable, CustomStringConvertible {
        case video, audio
        var description: String {
            self.rawValue.capitalized(with: Locale.current)
        }
    }
}

extension MetadataVideo {
    struct Stream: Codable, Identifiable, DictionaryKeyValueable {
        typealias Key = CodingKeys
        
        let id: UUID = UUID()
        let index: Int? // 0
        let codecName: String? // h264
        let codecLongName: String? // unknown
        let profile: String? // 100
        let codecType: CodecType? // video
        let width: Int? // 1920
        let height: Int? // 1080
        let displayAspectRatio: String? // 16:9
        let pixelFormat: String? // yuv420p
        let frameRate: Double? // 2997/125
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
        
        func value(for key: CodingKeys) -> String? {
            switch key {
            case .index:
                return self.index?.formatted()
            case .codecName:
                return self.codecName
            case .codecLongName:
                return self.codecLongName
            case .profile:
                return self.profile
            case .codecType:
                return self.codecType?.rawValue
            case .width:
                return self.width?.formatted()
            case .height:
                return self.height?.formatted()
            case .displayAspectRatio:
                return self.displayAspectRatio
            case .pixelFormat:
                return self.pixelFormat
            case .frameRate:
                return self.frameRate?.formatted()
            case .tags:
                return nil
            }
        }
        
        enum CodingKeys: String, CodingKey, CaseIterable, Keyable {
            case index = "index"
            case codecName = "codec_name"
            case codecLongName = "codec_long_name"
            case profile = "profile"
            case codecType = "codec_type"
            case width = "width"
            case height = "height"
            case displayAspectRatio = "display_aspect_ratio"
            case pixelFormat = "pix_fmt"
            case frameRate = "r_frame_rate"
            case tags
            
            var id: String {
                self.rawValue
            }
            
            var index: Int {
                Self.allCases.firstIndex(of: self) ?? .zero
            }
            
            var description: String {
                switch self {
                case .index:
                    return "Index"
                case .codecName:
                    return "Codec name"
                case .codecLongName:
                    return "Codec long name"
                case .profile:
                    return "Profile"
                case .codecType:
                    return "Codec type"
                case .width:
                    return "Width"
                case .height:
                    return "Height"
                case .displayAspectRatio:
                    return "Aspect ratio"
                case .pixelFormat:
                    return "Pixel format"
                case .frameRate:
                    return "Frame rate"
                case .tags:
                    return "Tags"
                }
            }
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<MetadataVideo.Stream.CodingKeys> = try decoder.container(keyedBy: MetadataVideo.Stream.CodingKeys.self)
            self.index = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Stream.CodingKeys.index)
            self.codecName = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.codecName)
            self.codecLongName = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.codecLongName)
            self.profile = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.profile)
            self.codecType = try container.decodeIfPresent(CodecType.self, forKey: MetadataVideo.Stream.CodingKeys.codecType)
            self.width = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Stream.CodingKeys.width)
            self.height = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Stream.CodingKeys.height)
            self.displayAspectRatio = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.displayAspectRatio)
            self.pixelFormat = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.pixelFormat)
            
            let frameRateRaw = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.frameRate)
            if let fraction = frameRateRaw?.split(separator: "/").map({ Double($0) ?? .zero }), let numerator = fraction.first, let denominator = fraction.last, denominator != .zero
            {
                self.frameRate = numerator / denominator
            } else {
                self.frameRate = nil
            }
            
            self.tags = try container.decodeIfPresent(MetadataVideo.Stream.Tags.self, forKey: MetadataVideo.Stream.CodingKeys.tags)
        }
    }
}

extension MetadataVideo.Stream {
    struct Tags: Codable, Identifiable, DictionaryKeyValueable {
        let id: UUID = UUID()
        let duration: String? // 00:47:09.622000000
        let numberOfFrames: Int? // 67843
        let numberOfBytes: Int? // 2404223327
        
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
            case .duration:
                return duration
            case .numberOfFrames:
                return numberOfFrames?.formatted()
            case .numberOfBytes:
                if let numberOfBytes {
                    let size = FileSize(size: Double(numberOfBytes), unit: .byte)
                    return size.optimal().description
                } else {
                    return nil
                }
            }
        }
        
        enum CodingKeys: String, CodingKey, CaseIterable, Keyable {
            case duration = "DURATION"
            case numberOfFrames = "NUMBER_OF_FRAMES"
            case numberOfBytes = "NUMBER_OF_BYTES"
            
            var id: String {
                self.rawValue
            }
            
            var index: Int {
                Self.allCases.firstIndex(of: self) ?? .zero
            }
            
            var description: String {
                switch self {
                case .duration:
                    return "Duration"
                case .numberOfFrames:
                    return "Number of frames"
                case .numberOfBytes:
                    return "Size"
                }
            }
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<MetadataVideo.Stream.Tags.CodingKeys> = try decoder.container(keyedBy: MetadataVideo.Stream.Tags.CodingKeys.self)
            self.duration = try container.decode(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.duration)
            let numberOfFrames = try container.decode(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.numberOfFrames)
            self.numberOfFrames = Int(numberOfFrames) ?? .zero
            let numberOfBytes = try container.decode(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.numberOfBytes)
            self.numberOfBytes = Int(numberOfBytes) ?? .zero
        }
    }
}

extension MetadataVideo {
    struct Format: Codable, Identifiable, DictionaryKeyValueable {
        let id: UUID = UUID()
        let fileName: String?
        let numberStreams: Int?
        let formatName: String?
        let startTime: String?
        let duration: Double?
        let size: Int?
        let bitRate: String?
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
            self.startTime = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.CodingKeys.startTime)
            let durationString = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.CodingKeys.duration)
            if let durationString {
                self.duration = Double(durationString)
            } else {
                self.duration = nil
            }
            if let sizeString = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.CodingKeys.size) {
                self.size = Int(sizeString)
            } else {
                self.size = nil
            }
            self.bitRate = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Format.CodingKeys.bitRate)
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
                return startTime
            case .duration:
                return duration?.formatted()
            case .size:
                if let size {
                    let sizeInBytes = FileSize(size: Double(size), unit: .byte)
                    return sizeInBytes.optimal().description
                } else {
                    return nil
                }
            case .bitRate:
                return bitRate
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
        let encoder: String?
        let creationTime: Date?
        
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
            case .encoder:
                return encoder
            case .creationTime:
                if let creationTime {
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone.current
                    dateFormatter.locale = Locale.current
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .medium
                    return dateFormatter.string(from: creationTime)
                } else {
                    return nil
                }
            }
        }
        
        enum CodingKeys: String, CodingKey, CaseIterable, Keyable {
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
                case .encoder:
                    return "Encoder"
                case .creationTime:
                    return "Creation time"
                }
            }
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<MetadataVideo.Format.Tags.CodingKeys> = try decoder.container(keyedBy: MetadataVideo.Format.Tags.CodingKeys.self)
            self.encoder = try container.decode(String.self, forKey: MetadataVideo.Format.Tags.CodingKeys.encoder)
            let creationTime = try container.decode(String.self, forKey: MetadataVideo.Format.Tags.CodingKeys.creationTime)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            self.creationTime = formatter.date(from: creationTime)
        }
    }
}
