//
//  MetadataVideoCodecType.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.12.2023.
//

import Foundation

extension MetadataVideo {
    enum CodecType: String, Codable, CustomStringConvertible {
        case video, audio, data, subtitle
        
        var description: String {
            self.rawValue.capitalized(with: Locale.current)
        }
    }
}
