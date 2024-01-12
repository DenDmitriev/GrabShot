//
//  CMTimeExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 12.01.2024.
//

import AVKit

extension CMTime {
    /// Длительность с окргулением по кол-ву кадров в секунду в видео
    func duration(frameRate: Double) -> Duration {
        let cmTimeFramRated = CMTime(seconds: seconds, preferredTimescale: Int32(frameRate.rounded(.up)))
        return Duration.seconds(cmTimeFramRated.seconds)
    }
}
