//
//  VimeoRequest.swift
//  VimeoPlayer
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import Foundation

struct VimeoResponse: Codable {
    let request: Files
    let video: Video
}

extension VimeoResponse {
    struct Files: Codable {
        let files: Progressive
    }
}

extension VimeoResponse.Files {
    struct Progressive: Codable {
        let progressive: [Video]
    }
}

extension VimeoResponse.Files.Progressive {
    /*
    {
        "profile": "164",
        "width": 640,
        "height": 360,
        "mime": "video/mp4",
        "fps": 25,
        "url": "https://vod-progressive.akamaized.net/exp=1705561370~acl=%2Fvimeo-transcode-storage-prod-us-west1-h264-360p%2F01%2F249%2F27%2F676247342%2F3115412808.mp4~hmac=2682e87d05b2d1d51a03ac5b2383c4038335226a515a19894275beff74355fa4/vimeo-transcode-storage-prod-us-west1-h264-360p/01/249/27/676247342/3115412808.mp4",
        "cdn": "akamai_interconnect",
        "quality": "360p",
        "id": "7efd2e49-72f4-4e2f-923f-5f4d04c9021e",
        "origin": "gcs"
    },
    */
    struct Video: Codable {
        let id: String
        let fps: Double
        let quality: Quality
        let width: Int
        let height: Int
        let mime: String
        let url: URL
    }
}

extension VimeoResponse.Files.Progressive {
    enum Quality: String {
        case quality360p = "360p"
        case quality540p = "540p"
        case quality640p = "640p"
        case quality720p = "720p"
        case quality960p = "960p"
        case quality1080p = "1080p"
        case qualityUnknown = "unknown"
    }
}

extension VimeoResponse.Files.Progressive.Quality: Codable {
    public init(from decoder: Decoder) throws {
        self = try VimeoResponse.Files.Progressive.Quality(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .qualityUnknown
    }
}

extension VimeoResponse {
    /*
     {
         "id": 676247342,
         "title": "Rick Astley - Never Gonna Give You Up (Official Music Video)",
         "width": 1280,
         "height": 720,
         "duration": 212,
         "url": "https://vimeo.com/676247342",
         "share_url": "https://vimeo.com/676247342",
         "embed_code": "<iframe title=\"vimeo-player\" src=\"https://player.vimeo.com/video/676247342?h=f0b527f0f2\" width=\"640\" height=\"360\" frameborder=\"0\"    allowfullscreen></iframe>",
         "hd": 1,
         "allow_hd": 1,
         "default_to_hd": 0,
         "privacy": "anybody",
         "embed_permission": "public",
         "thumbs": {
             "1280": "https://i.vimeocdn.com/video/1370406267-a173d632d91fd1e7aadf9839592000906ac68d150763d9cc5fec7686492a14de-d_1280",
             "640": "https://i.vimeocdn.com/video/1370406267-a173d632d91fd1e7aadf9839592000906ac68d150763d9cc5fec7686492a14de-d_640",
             "960": "https://i.vimeocdn.com/video/1370406267-a173d632d91fd1e7aadf9839592000906ac68d150763d9cc5fec7686492a14de-d_960",
             "base": "https://i.vimeocdn.com/video/1370406267-a173d632d91fd1e7aadf9839592000906ac68d150763d9cc5fec7686492a14de-d"
         },
         "lang": null,
         "owner": {
             "id": 166407088,
             "name": "Messaoud Djardi",
             "img": "https://i.vimeocdn.com/portrait/67174438_60x60",
             "img_2x": "https://i.vimeocdn.com/portrait/67174438_60x60",
             "url": "https://vimeo.com/user166407088",
             "account_type": ""
         },
         "spatial": 0,
         "live_event": null,
         "version": {
             "current": null,
             "available": null
         },
         "unlisted_hash": null,
         "rating": {
             "id": 3
         },
         "fps": 25,
         "channel_layout": "stereo"
     },
     */
    struct Video: Codable {
        let id: Int
        let title: String
        let width: Int
        let height: Int
        let duration: Double
        let fps: Double
        let thumbs: Thumbs
    }
}



extension VimeoResponse.Video {
    struct Thumbs: Codable {
        let thumbBase: URL?
        let thumb640: URL?
        let thumb960: URL?
        let thumb1280: URL?
        let thumbUnknown: URL?
        
        enum CodingKeys: String, CodingKey, CaseIterable {
            case thumbBase = "base"
            case thumb640 = "640"
            case thumb960 = "960"
            case thumb1280 = "1280"
            case thumbUnknown = "unknown"
            
            func url(_ thumb: Thumbs) -> URL? {
                switch self {
                case .thumbBase:
                    return thumb.thumbBase
                case .thumb640:
                    return thumb.thumbBase
                case .thumb960:
                    return thumb.thumb960
                case .thumb1280:
                    return thumb.thumb1280
                case .thumbUnknown:
                    return thumb.thumbUnknown
                }
            }
        }
    }
}


