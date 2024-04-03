//
//  YoutubeVideo.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.01.2024.
//

import Foundation

class YoutubeVideo: Video {
    let description: String?
    
    init(response: YoutubeResponse, store: VideoStore?) {
        self.description = response.description
        super.init(url: response.url, store: store, title: response.title)
        self.coverURL = coverURL
    }
}
