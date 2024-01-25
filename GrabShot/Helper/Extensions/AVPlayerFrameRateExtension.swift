//
//  AVPlayerExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.01.2024.
//

import AVKit

extension AVPlayer {
    var videoFrameRate: Double {
        let frameRate = currentItem?.tracks
            .first(where: { $0.assetTrack?.mediaType == .video })?
            .currentVideoFrameRate
        
        return Double(frameRate ?? 1.0)
    }
}
