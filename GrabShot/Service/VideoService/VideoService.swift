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
    
    /// Получение изображения из видео по таймкоду
    /// - Warning: Только для поддерживаемого формата `AVFoundation`
    /// - Returns: `CGImage`
    static func image(video url: URL, by time: CMTime) async throws -> CGImage {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let result = try await generator.image(at: time)
//        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        return result.image
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
    
    /// Создание скриншота для видео по указанному таймкоду
    static func grab(in video: Video, timecode: Duration, quality: Double, completion: @escaping (Result<URL,Error>) -> Void) {
        guard let exportDirectory = video.exportDirectory else {
            completion(.failure(VideoServiceError.exportDirectory))
            return
        }
        
        let urlRelativeString = video.url.absoluteString//.relativePath
        let qualityReduced = (100 - quality).rounded() / 10
        let timecodeFormatted = self.timecodeString(for: timecode, frameRate: video.frameRate)
        print(timecode.seconds, timecodeFormatted, video.frameRate)
        var urlImage = exportDirectory
        urlImage.append(path: video.grabName)
        urlImage.appendPathExtension(timecodeFormatted)
        urlImage.appendPathExtension("jpg")
        
        let arguments = [
            "-loglevel", "error", // "warning",
            "-y", //Overwrite output files without asking
            "-ss", "\(timecode.seconds)",
            "-i", "'\(urlRelativeString)'",
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
        default:
            let error = VideoServiceError.grab(video: video, timecode: timecode)
            completion(.failure(error))
        }
    }
    
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
//        let path = video.url.relativePath
//        let arguments = [
//            "-loglevel", "error", // "warning",
//            "-show_entries", "stream_tags:format_tags",
//            "-of", "json",
//            "'\(path)'",
//        ]
//        let command = arguments.joined(separator: " ")
//        
//        let session = FFprobeKit.execute(command)
//        
//        guard let state = session?.getState() else { return .failure(.commandFailure) }
//        switch state {
//        case .completed:
//            guard let output = session?.getOutput(),
//                  let json = output.data(using: .utf8)
//            else { return .failure(.parsingMetadataFailure) }
//            
//            do {
//                let metadata = try JSONDecoder().decode(MetadataVideo.self, from: json)
//                return .success(metadata)
//            } catch {
//                if let error = error as? LocalizedError {
//                    return .failure(.error(errorDescription: error.localizedDescription, recoverySuggestion: error.recoverySuggestion))
//                } else {
//                    return .failure(.parsingMetadataFailure)
//                }
//            }
//            
//        default:
//            let error = VideoServiceError.duration(video: video)
//            return .failure(.parsingMetadataFailure)
//        }
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
            "'\(input.relativePath)'",
            "-loglevel", "error", // "warning",
            "-codec", "copy",
            "'\(output.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        FFmpegKitConfig.enableLogCallback { log in
            if let message = log?.getMessage() {
                let error = VideoServiceError.error(errorDescription: message, recoverySuggestion: nil)
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
