//
//  MetadataItem.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.01.2024.
//

import SwiftUI
import MetadataVideoFFmpeg

extension MetadataVideoView {
    struct MetadataItem: Identifiable, Codable {
        let id: Int
        let key: String
        let value: String
        
        var description: String {
            [key, value].joined(separator: ": ")
        }
    }
    
    enum Key: CaseIterable, Keyable {
        case encoder, formatName, codecName, duration, frames, displayAspectRatio, width, height, fieldOrder, pixelFormat, frameRate, colorRange, colorSpace, bitDepth, bitRate, size, creationTime
        
        var index: Int {
            Self.allCases.firstIndex(of: self) ?? .zero
        }
        
        var id: Self {
            self
        }
        
        var description: String {
            switch self {
            case .frames:
                return StreamMetadata.CodingKeys.numberFrames.description
            case .frameRate:
                return StreamMetadata.CodingKeys.frameRate.description
            case .bitDepth:
                return StreamMetadata.CodingKeys.bitsPerSample.description
            case .duration:
                return FormatMetadata.CodingKeys.duration.description
            case .bitRate:
                return FormatMetadata.CodingKeys.bitRate.description
            case .formatName:
                return FormatMetadata.CodingKeys.formatName.description
            case .size:
                return FormatMetadata.CodingKeys.size.description
            case .creationTime:
                return FormatMetadata.Tags.CodingKeys.creationTime.description
            case .codecName:
                return StreamMetadata.CodingKeys.codecName.description
            case .width:
                return StreamMetadata.CodingKeys.width.description
            case .height:
                return StreamMetadata.CodingKeys.height.description
            case .colorRange:
                return StreamMetadata.CodingKeys.colorRange.description
            case .colorSpace:
                return StreamMetadata.CodingKeys.colorSpace.description
            case .displayAspectRatio:
                return StreamMetadata.CodingKeys.displayAspectRatio.description
            case .pixelFormat:
                return StreamMetadata.CodingKeys.pixelFormat.description
            case .fieldOrder:
                return StreamMetadata.CodingKeys.fieldOrder.description
            case .encoder:
                return StreamMetadata.Tags.CodingKeys.encoder.description
            }
        }
        
        func value(_ metadata: MetadataVideo) -> String? {
            guard let stream = stream(metadata) else { return nil }
            switch self {
            case .frames:
                return stream.value(for: .numberFrames)
            case .frameRate:
                return stream.value(for: .frameRate)
            case .bitDepth:
                return stream.value(for: .bitsPerRawSample)
            case .duration:
                return metadata.format.value(for: .duration)
            case .bitRate:
                return metadata.format.value(for: .bitRate)
            case .formatName:
                return metadata.format.value(for: .formatName)
            case .size:
                return metadata.format.value(for: .size)
            case .creationTime:
                return metadata.format.tags?.value(for: .creationTime)
            case .codecName:
                return stream.value(for: .codecName)
            case .width:
                return stream.value(for: .width)
            case .height:
                return stream.value(for: .height)
            case .colorRange:
                return stream.value(for: .colorRange)
            case .colorSpace:
                return stream.value(for: .colorSpace)
            case .displayAspectRatio:
                return stream.value(for: .displayAspectRatio)
            case .pixelFormat:
                return stream.value(for: .pixelFormat)
            case .fieldOrder:
                return stream.value(for: .fieldOrder)
            case .encoder:
                return stream.tags?.value(for: .encoder)
            }
        }
        
        private func stream(_ metadata: MetadataVideo) -> StreamMetadata? {
            metadata.streams.first(where: { $0.codecType == .video })
        }
    }
}

extension MetadataVideoView.MetadataItem: Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .text)
        ProxyRepresentation(exporting: \.description)
    }
}
