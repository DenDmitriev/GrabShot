//
//  VideoService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 20.11.2022.
//

//import Cocoa
import AVFoundation
import ffmpegkit
import MetadataVideoFFmpeg

class VideoService {
    
    /// Cancels all running sessions.
    static func cancel() {
        FFmpegKit.cancel()
    }
    
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
    
    enum Destination {
        case cache, exportDirectory
        
        var url: URL? {
            switch self {
            case .cache:
                FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            case .exportDirectory:
                nil
            }
        }
    }
    
    /// Создание скриншота для видео по указанному таймкоду
    static func grab(in video: Video, to destination: Destination = .exportDirectory, timecode: Duration, quality: Double, completion: @escaping (Result<URL,Error>) -> Void) {
        let exportDirectory: URL?
        switch destination {
        case .cache:
            exportDirectory = destination.url
        case .exportDirectory:
            exportDirectory = video.exportDirectory
        }
        
        guard let exportDirectory else {
            completion(.failure(VideoServiceError.exportDirectory))
            return
        }
        
        let urlRelativeString = video.url.absoluteString
        let qualityReduced = (100 - quality).rounded() / 10
        let timecodeFormatted = self.timecodeString(for: timecode, frameRate: video.frameRate)
        var urlImage = exportDirectory
        urlImage.append(path: video.grabName)
        urlImage.appendPathExtension(timecodeFormatted)
        urlImage.appendPathExtension("jpg")
        
        let arguments = [
            "-loglevel", "error", // "warning",
            "-y", //Overwrite output files without asking
            "-ss", "\(timecode.seconds)",
            "-i", "'\(urlRelativeString)'",
            "-update", "1", // Указывает что будет одно изображение обновляться. Для отключения предупреждения
            "-frames:v", "1", //Set the number of video frames to output  -vframes
            "-f", "mjpeg",
            "-pix_fmt", "yuvj420p", //Set pixel format
            "-q:v", "\(qualityReduced)",
            "'\(urlImage.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        let session = FFmpegKit.execute(command)
        guard let state = session?.getState() else { return }
        switch state {
        case .completed:
            completion(.success(urlImage))
        case .failed:
            if let failDescription = session?.getFailStackTrace() {
                let error = VideoServiceError.error(errorDescription: failDescription, failureReason: nil)
                completion(.failure(error))
            }
        default:
            let error = VideoServiceError.grab(video: video, timecode: timecode)
            completion(.failure(error))
        }
    }
    
    /// Создание скриншота для видео по указанному таймкоду асинхронно
    static func grab(in video: Video, to destination: Destination, timecode: Duration, quality: Double) async throws -> Result<URL, Error> {
        try await withCheckedThrowingContinuation { continuation in
            Self.grab(in: video, to: destination, timecode: timecode, quality: quality) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Создание скриншотов для видео
    static func grab(in video: Video, from: Duration, to: Duration, period: Int = 5, completion: @escaping (Result<(URL, Int),Error>) -> Void) {
        guard let exportDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(.failure(VideoServiceError.exportDirectory))
            return
        }
        
        let urlRelativeString = video.url.absoluteString // нужно сделать раздедение
        var urlImage = exportDirectory
        urlImage.append(path: video.grabName)
        urlImage.appendPathExtension("%d") // Filename pattern  image.1.png, image.2.png, ...
        urlImage.appendPathExtension("jpg")
        let countImages = (to - from).seconds / Double(period)
        
        // ffmpeg -i /Users/denisdmitriev/Movies/FarAway.mov -ss 51.9275129253125 -t 181.208333 -vf fps=1/5 -pix_fmt yuvj420p -q:v 7 /Users/denisdmitriev/Movies/FarAwayShort/image.%d.jpg
        let arguments = [
            "-loglevel", "error", // "warning",
            "-y",
            "-i", "'\(urlRelativeString)'",
            "-ss", "\(from.seconds)",
            "-to", "\(to.seconds)",
            "-vf", "fps=1/\(period)", //Set the number of video frames to output  1/5 every 5 seconds
            "-pix_fmt", "yuv420p", //Set pixel format
            "-q:v", "\(7)", // compressing 1 : 7
            "'\(urlImage.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        let session = FFmpegKit.execute(command)
        guard let state = session?.getState() else { return }
        switch state {
        case .completed:
            completion(.success((urlImage, Int(countImages))))
        case .failed:
            if let failDescription = session?.getFailStackTrace() {
                let error = VideoServiceError.error(errorDescription: failDescription, failureReason: nil)
                completion(.failure(error))
            }
        default:
            if let failDescription = session?.getFailStackTrace() {
                print(#function, failDescription)
            }
            let error = VideoServiceError.grab(video: video, timecode: from)
            completion(.failure(error))
        }
    }
    
    static func grab(in video: Video, from: Duration, to: Duration, period: Int = 5) async throws -> Result<(URL, Int), Error> {
        try await withCheckedThrowingContinuation { continuation in
            grab(in: video, from: from, to: to, period: period) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Создание отрезка  видео по указанному таймкоду
    static func cut(in video: Video, from: Duration, to: Duration, callBackProgress: @escaping ((Progress) -> Void), completion: @escaping (Result<URL,Error>) -> Void) {
        guard let exportDirectory = video.exportDirectory else {
            completion(.failure(VideoServiceError.exportDirectory))
            return
        }
        
        let urlRelativeString = video.url.absoluteString
        let fromFormatted = self.timecodeString(for: from, frameRate: video.frameRate)
        let toFormatted = self.timecodeString(for: to, frameRate: video.frameRate)
        var urlVideo = exportDirectory
        urlVideo.append(path: video.grabName)
        urlVideo.appendPathExtension(fromFormatted + "-" + toFormatted)
        urlVideo.appendPathExtension("mov")
        
        let totalFrames: Int = Int(((to - from).seconds * video.frameRate).rounded(.up))
        
        let arguments = [
            "-loglevel", "error", // "warning",
            "-progress - -nostats", // statistic callback
            "-y", //Overwrite output files without asking
            "-i", "'\(urlRelativeString)'",
            "-ss", "\(from.seconds)",
            "-to", "\(to.seconds)",
            "-c:v", "copy", // commands copy the original video without re-encoding
            "-c:a", "copy", // commands copy the original audio without re-encoding
            "'\(urlVideo.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        FFmpegKit.executeAsync(command, withCompleteCallback: { session in
            guard let state = session?.getState() else { return }
            switch state {
            case .running:
                print("⏱️")
            case .completed:
                completion(.success(urlVideo))
            case .failed:
                if let failDescription = session?.getFailStackTrace() {
                    let error = VideoServiceError.error(errorDescription: failDescription, failureReason: nil)
                    completion(.failure(error))
                }
            default:
                let error = VideoServiceError.cut(video: video)
                completion(.failure(error))
            }
        }, withLogCallback: { _ in
            // add log callback
        }, withStatisticsCallback: { statistics in
            let frameNumber = statistics?.getVideoFrameNumber() ?? .zero
            let progress = Progress(value: Int(frameNumber), total: totalFrames)
            callBackProgress(progress)
        }, onDispatchQueue: .global(qos: .utility))
    }
    
    /// Создание обложки для видео в низком разрешении в папку для временного хранения
    static func thumbnail(for video: Video, timecode: Duration = .seconds(30), update: UpdateThumbnail? = nil, completion: @escaping ((Result<URL, Error>) -> Void)) {
        // ffmpeg -ss 00:00:01.00 -i input.mp4 -vf 'scale=320:320:force_original_aspect_ratio=decrease' -vframes 1 output.jpg
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(.failure(VideoServiceError.cacheDirectory))
            return
        }
        
        // Вычисляю время для обложки. Проверяю на длительность и назначаю новое время если нужно обновление.
        var timecode = video.duration >= timecode.seconds ? timecode : .seconds(video.duration / 2)
        if let update {
            let previousTimecode = update.url.deletingPathExtension().pathExtension
            let nextTimecode: Duration = .seconds((Double(previousTimecode) ?? .zero) + 30.0)
            if nextTimecode.seconds <= video.duration {
                timecode = nextTimecode
            } else {
                timecode = .seconds(timecode.seconds + 1)
            }
        }
        let stringTimecode = timecode.formatted(.timecode(frameRate: video.frameRate, separator: "."))
        let thumbnailName = video.title + ".thumbnail" + ".\(stringTimecode)" + ".jpeg"
        let urlImage = cachesDirectory.appendingPathComponent(thumbnailName)
        
        guard !FileManager.default.fileExists(atPath: urlImage.path) else {
            completion(.success(urlImage))
            return
        }

        let arguments: [String] = [
            "-loglevel", "error", // "warning",
            "-y",
            "-ss", timecode.formatted(),
            "-i", "'\(video.url.absoluteString)'",
            "-vf", "'scale=320:320:force_original_aspect_ratio=decrease'",
            "-vframes:v", "1",
            "'\(urlImage.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        let session = FFmpegKit.execute(command)
        guard let state = session?.getState() else { return }
        switch state {
        case .completed:
            completion(.success(urlImage))
        default:
            let error = VideoServiceError.grab(video: video, timecode: timecode)
            completion(.failure(error))
        }
    }
    
    //MARK: - Private
    
    /// Получение длины для видео в секундах
    static func duration(for video: Video, completion: @escaping ((Result<TimeInterval, Error>) -> Void)) {
        let path = video.url.absoluteString
        let arguments = [
            "'\(path)'",
            "-loglevel", "error", // "warning",
            "-v", "quiet",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1"
        ]
        let command = arguments.joined(separator: " ")
        
        let session = FFprobeKit.execute(command)
        
        guard let state = session?.getState() else { return }
        switch state {
        case .completed:
            guard let output = session?.getOutput() else { return }
            let duration = (output as NSString).doubleValue
            completion(.success(duration))
        default:
            let error = VideoServiceError.duration(video: video)
            completion(.failure(error))
        }
    }
    
    /// Получение метаданных видео
    /// `ffprobe -loglevel error -show_entries stream_tags:format_tags -of json video.mov`
    static func getMetadata(of video: Video) -> Result<MetadataVideo, VideoServiceError> {
        let path = video.url.absoluteString
        let mediaInformation = FFprobeKit.getMediaInformation(path)
        let metadataRaw = mediaInformation?.getOutput()
        guard let metadataRaw else { return .failure(.commandFailure) }
        do {
            let formatted = metadataRaw
                .replacingOccurrences(of: "\\n", with: "\n")
                .replacingOccurrences(of: "\\\u{22}", with: "\u{22}")
            guard let data = formatted.data(using: .utf8) else { return .failure(.parsingMetadataFailure) }
            let metadata = try JSONDecoder().decode(MetadataVideo.self, from: data)
            return .success(metadata)
        } catch {
            return .failure(.parsingMetadataFailure)
        }
    }
    
    static func durationAsync(for video: Video) async throws -> TimeInterval {
        try await withCheckedThrowingContinuation { continuation in
            duration(for: video) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
                
            }
        }
    }
    
    /// Копирование медиа потока в кодеке
    static func cache(for video: Video, completion: @escaping ((Result<URL, Error>) -> Void)) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(.failure(VideoServiceError.cacheDirectory))
            return
        }
        let input = video.url
        let cacheName = video.title + ".cache" + ".mov"
        let output = cachesDirectory.appendingPathComponent(cacheName)
        
        guard !FileManager.default.fileExists(atPath: output.path) else {
            completion(.success(output))
            return
        }
        
        let arguments = [
            "-i",
            "'\(input.absoluteString)'",
            "-loglevel", "error", // "warning",
            "-codec", "copy",
            "'\(output.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        FFmpegKitConfig.enableLogCallback { log in
            if let message = log?.getMessage() {
                let error = VideoServiceError.error(errorDescription: message, failureReason: nil)
                completion(.failure(error))
            }
        }
        let session = FFmpegKit.execute(command)
        
        guard let state = session?.getState() else { return }
        switch state {
        case .completed:
            session?.getLogs()
            completion(.success(output))
        default:
            let error = VideoServiceError.createCacheVideoFailure
            completion(.failure(error))
        }
    }
    
    /// Форматирование секундного таймкода `119 seconds` в  текстовый `00:01:59:00` для включения в имя файла
    private static func timecodeString(for timecode: Duration, frameRate: Double) -> String {
        let string = timecode.formatted(.timecode(frameRate: frameRate, separator: "."))
        return string
    }
}

extension VideoService {
    struct UpdateThumbnail {
        let url: URL
        
        init?(url: URL?) {
            if let url {
                self.url = url
            } else {
                return nil
            }
        }
    }
}

extension VideoService {
    struct Progress {
        let value: Int
        let total: Int
    }
}
