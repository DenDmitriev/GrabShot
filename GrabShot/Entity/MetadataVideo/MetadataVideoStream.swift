//
//  MetadataVideo+Stream.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.12.2023.
//

import Foundation

extension MetadataVideo {
    struct Stream: Codable, Identifiable, DictionaryKeyValueable {
        typealias Key = CodingKeys
        
        let id: UUID = UUID()
        let index: Int? // 0
        let codecName: String? // h264
        let codecLongName: String? // unknown
        let profile: String? // 100
        let codecType: CodecType? // video
        let codecTagString: String? // video
        let width: Int? // 1920
        let height: Int? // 1080
        let colorRange: String? // tv
        let colorSpace: String? // bt709
        let fieldOrder: String? // progressive
        let displayAspectRatio: String? // 16:9
        let pixelFormat: String? // yuv420p
        let frameRate: Double? // 2997/125
        let duration: Duration? // 5.000000
        let startTime: Duration? // 0.0
        let bitRate: Int? // 42934
        let bitsPerRawSample: Int? // 8
        let numberFrames: String? // 120
        let sampleRate: Int? // "sample_rate": "48000",
        let channels: Int? // "channels": 6,
        let channelLayout: String? // "channel_layout": "5.1(side)",
        let bitsPerSample: Int? // "bits_per_sample": 0,
        let timeBase: String? // "time_base": "1/1000"
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
            case .codecTagString:
                return self.codecTagString
            case .width:
                return self.width?.formatted()
            case .height:
                return self.height?.formatted()
            case .colorRange:
                return self.colorRange
            case .colorSpace:
                return self.colorSpace
            case .displayAspectRatio:
                return self.displayAspectRatio
            case .pixelFormat:
                return self.pixelFormat
            case .frameRate:
                return self.frameRate?.formatted()
            case .tags:
                return nil
            case .duration:
                return self.duration?.formatted(.time(pattern: .hourMinuteSecond))
            case .startTime:
                return self.startTime?.formatted(.time(pattern: .hourMinuteSecond))
            case .bitRate:
                return MetadataVideo.fileSizeFormatted(value: bitRate, unit: .byte, rule: .down)
            case .bitsPerRawSample:
                return MetadataVideo.fileSizeFormatted(value: bitsPerRawSample, unit: .bit)
            case .numberFrames:
                return self.numberFrames
            case .fieldOrder:
                return self.fieldOrder
            case .sampleRate:
                return self.sampleRate?.formatted(.hertz)
            case .channels:
                return self.channels?.formatted()
            case .channelLayout:
                return self.channelLayout
            case .timeBase:
                return self.timeBase
            case .bitsPerSample:
                return MetadataVideo.fileSizeFormatted(value: bitsPerSample, unit: .bit, rule: .down)
            }
        }
        
        enum CodingKeys: String, CodingKey, CaseIterable, Keyable {
            case index = "index"
            case codecName = "codec_name"
            case codecLongName = "codec_long_name"
            case profile = "profile"
            case codecType = "codec_type"
            case codecTagString = "codec_tag_string"
            case width = "width"
            case height = "height"
            case colorRange = "color_range"
            case colorSpace = "color_space"
            case displayAspectRatio = "display_aspect_ratio"
            case pixelFormat = "pix_fmt"
            case fieldOrder = "field_order"
            case frameRate = "r_frame_rate"
            case duration = "duration"
            case startTime = "start_time"
            case bitRate = "bit_rate"
            case bitsPerRawSample = "bits_per_raw_sample"
            case numberFrames = "nb_frames"
            case sampleRate = "sample_rate"
            case channels = "channels"
            case channelLayout = "channel_layout"
            case bitsPerSample = "bits_per_sample"
            case timeBase = "time_base"
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
                case .codecTagString:
                    return "Codec Tag String"
                case .colorRange:
                    return "Color range"
                case .colorSpace:
                    return "Color space"
                case .startTime:
                    return "Start time"
                case .duration:
                    return "Duration"
                case .bitRate:
                    return "Bit rate"
                case .bitsPerRawSample:
                    return "Bits Per Raw Sample"
                case .numberFrames:
                    return "Number frames"
                case .fieldOrder:
                    return "Field order"
                case .sampleRate:
                    return "Sample rate"
                case .channels:
                    return "Channels"
                case .channelLayout:
                    return "Channel layout"
                case .bitsPerSample:
                    return "Bits per sample"
                case .timeBase:
                    return "Time base"
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
            self.codecTagString = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.codecTagString)
            self.width = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Stream.CodingKeys.width)
            self.height = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Stream.CodingKeys.height)
            self.colorRange = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.colorRange)
            self.colorSpace = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.colorSpace)
            self.fieldOrder = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.fieldOrder)
            self.displayAspectRatio = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.displayAspectRatio)
            self.pixelFormat = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.pixelFormat)
            let frameRateRaw = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.frameRate)
            if let fraction = frameRateRaw?.split(separator: "/").map({ Double($0) ?? .zero }), let numerator = fraction.first, let denominator = fraction.last, denominator != .zero
            {
                self.frameRate = numerator / denominator
            } else {
                self.frameRate = nil
            }
            self.duration = try MetadataVideo.decodeIfPresentDuration(container: container, key: .duration)
            self.startTime = try MetadataVideo.decodeIfPresentDuration(container: container, key: .startTime)
            self.bitRate = try MetadataVideo.decodeIfPresentInt(container: container, key: .bitRate)
            self.bitsPerRawSample = try MetadataVideo.decodeIfPresentInt(container: container, key: .bitsPerRawSample)
            self.numberFrames = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.numberFrames)
            self.sampleRate = try MetadataVideo.decodeIfPresentInt(container: container, key: .sampleRate)
            self.channels = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Stream.CodingKeys.channels)
            self.channelLayout = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.channelLayout)
            self.bitsPerSample = try container.decodeIfPresent(Int.self, forKey: MetadataVideo.Stream.CodingKeys.bitsPerSample)
            self.timeBase = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.CodingKeys.timeBase)
            self.tags = try container.decodeIfPresent(MetadataVideo.Stream.Tags.self, forKey: MetadataVideo.Stream.CodingKeys.tags)
        }
    }
}

extension MetadataVideo.Stream {
    struct Tags: Codable, Identifiable, DictionaryKeyValueable {
        let id: UUID = UUID()
        let language: String?
        let title: String?
        let duration: String? // 00:47:09.622000000
        let numberOfFrames: Int? // 67843
        let numberOfBytes: Int? // 2404223327
        let creationTime: Date? // "2023-11-29T14:41:04.000000Z"
        let handlerName: String? // "VideoHandler"
        let vendorId: String? //
        let encoder: String? // "H.264"
        let timecode: String? // "01:00:00:00"
        
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
            case .language:
                return language
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
            case .creationTime:
                if let creationTime {
                    let stringDate = MetadataVideo.dateFormatter.string(from: creationTime)
                    return stringDate
                } else {
                    return nil
                }
            case .handlerName:
                return self.handlerName
            case .vendorId:
                return self.vendorId
            case .encoder:
                return self.encoder
            case .timecode:
                return self.timecode
            }
        }
        
        enum CodingKeys: String, CodingKey, CaseIterable, Keyable {
            case language
            case title
            case duration = "DURATION"
            case numberOfFrames = "NUMBER_OF_FRAMES"
            case numberOfBytes = "NUMBER_OF_BYTES"
            case creationTime = "creation_time"
            case handlerName = "handler_name"
            case vendorId = "vendor_id"
            case encoder = "encoder"
            case timecode = "timecode"
            
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
                case .language:
                    return "Language"
                case .duration:
                    return "Duration"
                case .numberOfFrames:
                    return "Number of frames"
                case .numberOfBytes:
                    return "Size"
                case .creationTime:
                    return "Creation time"
                case .handlerName:
                    return "Handler name"
                case .vendorId:
                    return "Vendor ID"
                case .encoder:
                    return "Encoder"
                case .timecode:
                    return "Timecode"
                }
            }
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<MetadataVideo.Stream.Tags.CodingKeys> = try decoder.container(keyedBy: MetadataVideo.Stream.Tags.CodingKeys.self)
            self.title = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.title)
            self.language = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.language)
            self.duration = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.duration)
            self.numberOfFrames = try MetadataVideo.decodeIfPresentInt(container: container, key: .numberOfFrames)
            self.numberOfBytes = try MetadataVideo.decodeIfPresentInt(container: container, key: .numberOfBytes)
            if let creationTime = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.creationTime) {
                let formatter = MetadataVideo.dateFormatterDecoder
                self.creationTime = formatter.date(from: creationTime)
            } else {
                self.creationTime = nil
            }
            self.handlerName = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.handlerName)
            self.vendorId = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.vendorId)
            self.encoder = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.encoder)
            self.timecode = try container.decodeIfPresent(String.self, forKey: MetadataVideo.Stream.Tags.CodingKeys.timecode)
        }
    }
}
