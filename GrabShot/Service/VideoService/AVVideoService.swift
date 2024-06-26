//
//  AVVideoService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 24.01.2024.
//

import Foundation
import AVFoundation
import FirebaseCrashlytics

class AVVideoService {
    /// Получение изображения из видео по таймкоду
    /// - Warning: Только для поддерживаемого формата `AVFoundation`
    /// - Returns: `CGImage`
    static func image(video url: URL, by time: CMTime) async -> Result<CGImage, Error> {
        var url = url
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            urlComponents.queryItems = nil
            if let urlFormatted = urlComponents.url { url = urlFormatted }
        }
        
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        
        // Configure the generator's time tolerance values.
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = CMTime(seconds: 2, preferredTimescale: 600)
        
        generator.appliesPreferredTrackTransform = true
        do {
            let (image, _) = try await generator.image(at: time)
            return .success(image)
        } catch {
            Crashlytics.crashlytics().record(error: error, userInfo: ["function": #function, "object": type(of: self)])
            return .failure(error)
        }
    }
    
    /// Получение очереди изображений из видео по таймкоду
    /// - Documentation: https://developer.apple.com/documentation/avfoundation/media_reading_and_writing/creating_images_from_a_video_asset
    /// - Parameter url: Ссылка на видео которое поддерживается `AVFoundation`.
    /// - Parameter times: An array of times at which to create images.
    /// - Warning: Только для поддерживаемого формата `AVFoundation`
    /// - Returns: `CGImage`
    static func images(video url: URL, by times: [CMTime]) async throws -> Result<[CGImage], Error> {
        var url = url
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            urlComponents.queryItems = nil
            if let urlFormatted = urlComponents.url { url = urlFormatted }
        }
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        
        // Configure the generator's time tolerance values.
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = CMTime(seconds: 2, preferredTimescale: 600)
        
        generator.appliesPreferredTrackTransform = true
        
        var images: [CGImage] = []
        var operationTime: CMTime = .zero
        
        for try await result in generator.images(for: times) {
            let image = try result.image
            images.append(image)
            
            let actualTime = try result.actualTime
            operationTime = CMTimeAdd(operationTime, actualTime)
        }
        
        return .success(images)
    }
    
    /// Получение изображения из видео по таймкоду
    /// - Warning: Только для поддерживаемого формата `AVFoundation`
    /// - Returns: `CGImage`
    static func image(video url: URL, by timecode: Duration, frameRate: Double) throws -> CGImage {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timescale = Int32(frameRate)
        let time = CMTime(seconds: timecode.seconds, preferredTimescale: timescale)
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        return cgImage
    }
}
