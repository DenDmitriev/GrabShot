//
//  VimeoVideo.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import Foundation

class VimeoVideo: Video {
    let urlVideos: [URLVideo]
    let thumbs: [URLThumbQuality]
    
    init?(response: VimeoResponse, store: VideoStore?) {
        var urlVideos = response.request.files.progressive.compactMap({ file -> VimeoVideo.URLVideo? in
            return .init(quality: file.quality, url: file.url, size: .init(width: file.width, height: file.height))
        })
        let thumbs = VimeoResponse.Video.Thumbs.CodingKeys.allCases.compactMap { quality -> URLThumbQuality? in
            guard let url = quality.url(response.video.thumbs) else { return nil }
            return URLThumbQuality(quality: quality, url: url)
        }
        var size: CGSize? = CGSize(width: response.video.width, height: response.video.height)
        
        if let cdnPlayer = response.request.files.hls.defaultPlayer {
            let urlVideo = URLVideo(quality: .qualityUnknown, url: cdnPlayer.url, size: nil)
            urlVideos.append(urlVideo)
        }
        
        guard let urlVideo = urlVideos.highestResolutionURLVideo else { return nil }
        
        if urlVideo.size != size {
            size = urlVideo.size
        }
        
        let url = urlVideo.url
        let title = response.video.title
        let coverURL = thumbs.first?.url
        let duration = response.video.duration
        let frameRate = response.video.fps
        self.urlVideos = urlVideos
        self.thumbs = thumbs
        
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

extension Array<VimeoVideo.URLVideo> {
    var highestResolutionURLVideo: VimeoVideo.URLVideo? {
        self.max { lhs, rhs in
            if let lhsSize = lhs.size, let rhsSize = rhs.size {
                lhsSize.width < rhsSize.width
            } else {
                false
            }
        }
    }
    
    var lowestResolutionURLVideo: VimeoVideo.URLVideo? {
        self.min { lhs, rhs in
            if let lhsSize = lhs.size, let rhsSize = rhs.size {
                lhsSize.width < rhsSize.width
            } else {
                false
            }
        }
    }
}

extension VimeoVideo {
    struct URLVideo {
        let quality: VimeoResponse.Files.Progressive.Quality
        let url: URL
        let size: CGSize?
    }
    
    struct URLThumbQuality {
        let quality: VimeoResponse.Video.Thumbs.CodingKeys
        let url: URL
    }
}
