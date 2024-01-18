//
//  VimeoVideo.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import Foundation

class VimeoVideo: Video {
    let qualityUrls: [URLVideoQuality]
    let thumbs: [URLThumbQuality]
    
    init(response: VimeoResponse, store: VideoStore?) {
        self.qualityUrls = response.request.files.progressive.compactMap({ file -> VimeoVideo.URLVideoQuality? in
            return .init(quality: file.quality, url: file.url, size: .init(width: file.width, height: file.height))
        })
        self.thumbs = VimeoResponse.Video.Thumbs.CodingKeys.allCases.compactMap { quality -> URLThumbQuality? in
            guard let url = quality.url(response.video.thumbs) else { return nil }
            return URLThumbQuality(quality: quality, url: url)
        }
        let size = CGSize(width: response.video.width, height: response.video.height)
        let url = qualityUrls.first(where: { $0.size == size })?.url ?? Video.placeholder.url
        let title = response.video.title
        let coverURL = thumbs.first?.url
        let duration = response.video.duration
        let frameRate = response.video.fps
        
        super.init(
            url: url,
            title: title,
            coverURL: coverURL,
            size: size,
            duration: duration,
            frameRate: frameRate,
            store: store
        )
    }
}

extension VimeoVideo {
    struct URLVideoQuality {
        let quality: VimeoResponse.Files.Progressive.Quality
        let url: URL
        let size: CGSize
    }
    
    struct URLThumbQuality {
        let quality: VimeoResponse.Video.Thumbs.CodingKeys
        let url: URL
    }
}
