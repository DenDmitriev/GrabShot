//
//  VideoService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 20.11.2022.
//

//import Cocoa
import AVFoundation
import ffmpegkit

class VideoService {
    
    /// Создание скриншота для видео по указанному таймкоду
    static func grab(in video: Video, timecode: TimeInterval, quality: Double, completion: @escaping (Result<URL,Error>) -> Void) {
        guard let exportDirectory = video.exportDirectory else {
            completion(.failure(VideoServiceError.exportDirectory))
            return
        }
        
        let urlRelativeString = video.url.relativePath
        let qualityReduced = (100 - quality).rounded() / 10
        let timecodeFormatted = self.timecodeString(for: timecode)
        var urlImage = exportDirectory
        urlImage.append(path: video.title)
        urlImage.appendPathExtension(timecodeFormatted)
        urlImage.appendPathExtension("jpg")
        
        let arguments = [
            "-loglevel", "error", // "warning",
            "-y", //Overwrite output files without asking
            "-ss", "\(timecode)",
            "-i", "'\(urlRelativeString)'",
            "-frames:v", "1", //Set the number of video frames to output  -vframes
            "-f", "mjpeg",
            "-pix_fmt", "yuvj420p", //Set pixel format
            "-q:v", "\(qualityReduced)",
            "'\(urlImage.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        FFmpegKit.executeAsync(command) { session in
            guard let state = session?.getState() else { return }
            switch state {
            case .completed:
                completion(.success(urlImage))
            default:
                let error = VideoServiceError.grab(video: video, timecode: timecode)
                completion(.failure(error))
            }
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
    static func thumbnail(for video: Video, timecode: TimeInterval = 30, update: UpdateThumbnail? = nil, completion: @escaping ((Result<URL, Error>) -> Void)) {
        // ffmpeg -ss 00:00:01.00 -i input.mp4 -vf 'scale=320:320:force_original_aspect_ratio=decrease' -vframes 1 output.jpg
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(.failure(VideoServiceError.cacheDirectory))
            return
        }
        
        // Вычесляю время для обложки. Проверяю на длительность и назначаю новое время если нужно обновление.
        var timecode = video.duration >= timecode ? timecode : video.duration / 2
        if let update {
            let previousTimecode = update.url.deletingPathExtension().pathExtension
            let nextTimecode = (Double(previousTimecode) ?? .zero) + 30.0
            if nextTimecode <= video.duration {
                timecode = nextTimecode
            } else {
                timecode = 1
            }
        }
        
        let thumbnailName = video.title + ".thumbnail" + ".\(Int(timecode))" + ".jpeg"
        let urlImage = cachesDirectory.appendingPathComponent(thumbnailName)
        
        guard !FileManager.default.fileExists(atPath: urlImage.path) else {
            completion(.success(urlImage))
            return
        }

        let arguments: [String] = [
            "-loglevel", "error", // "warning",
            "-y",
            "-ss", timecode.formatted(),
            "-i", "'\(video.url.relativePath)'",
            "-vf", "'scale=320:320:force_original_aspect_ratio=decrease'",
            "-vframes", "1",
            "'\(urlImage.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        FFmpegKit.executeAsync(command) { session in
            guard let state = session?.getState() else { return }
            switch state {
            case .completed:
                completion(.success(urlImage))
            default:
                let error = VideoServiceError.grab(video: video, timecode: timecode)
                completion(.failure(error))
            }
        }
    }
    
    //MARK: - Private
    
    /// Получение длины для видео в секундах
    static func duration(for video: Video, completion: @escaping ((Result<TimeInterval, Error>) -> Void)) {
        let path = video.url.relativePath
        let arguments = [
            "'\(path)'",
            "-loglevel", "error", // "warning",
            "-v", "quiet",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1"
        ]
        let command = arguments.joined(separator: " ")
        
        FFprobeKit.executeAsync(command) { session in
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
    }
    
    /// Форматирование секундного таймкода в стандартный для включения в имя файла
    private static func timecodeString(for timecode: TimeInterval) -> String {
        let formatter: DateComponentsFormatter = {
            let format = DateComponentsFormatter()
            format.allowedUnits = [.hour, .minute, .second]
            format.unitsStyle = .positional
            format.maximumUnitCount = 3
            format.zeroFormattingBehavior = .pad
            return format
        }()
        let string = formatter.string(from: timecode) ?? String(timecode)
        let formattedFileName = string.replacingOccurrences(of: ":", with: ".")
        return formattedFileName
    }
}
