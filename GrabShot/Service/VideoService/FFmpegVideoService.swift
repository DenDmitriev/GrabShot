//
//  VideoService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 20.11.2022.
//

import ffmpegkit
import MetadataVideoFFmpeg

class FFmpegVideoService {
    
    /// Cancels all running sessions.
    /// Кажется не  работает.
    static func cancel() {
        FFmpegKit.cancel()
    }
    
    /// Создание скриншота для видео по указанному таймкоду.
    /// Для скорости кодек экспорта как у исходного файла.
    /// Контейнер используется Quicktime.
    /// - Parameters:
    ///   - video: Video которое поддеживается FFmpeg.
    ///   - to: `Destination` указывает папку экспорта для результата.
    ///   - timecode: `Duration` таймкод для скриншота.
    ///   - quality: `Double` уровень компресси для скриншота. Чем больше, тем меньше сжатие и больше размер.
    /// - Returns:
    /// - completion: `URL` полученного скрнишота.
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
    
    /// Создание скриншота для видео по указанному таймкоду асинхронно.
    /// Для скорости кодек экспорта как у исходного файла.
    /// Контейнер используется Quicktime.
    /// - Parameters:
    ///   - video: Video которое поддеживается FFmpeg.
    ///   - to: `Destination` указывает папку экспорта для результата.
    ///   - timecode: `Duration` таймкод для скриншота.
    ///   - quality: `Double` уровень компресси для скриншота. Чем больше, тем меньше сжатие и больше размер.
    /// - Returns:
    /// - completion: `URL` полученного скрнишота.
    static func grab(in video: Video, to destination: Destination, timecode: Duration, quality: Double) async throws -> Result<URL, Error> {
        try await withCheckedThrowingContinuation { continuation in
            Self.grab(in: video, to: destination, timecode: timecode, quality: quality) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Создание скриншотов для видео
    /// - Warning: Долго работает.
    static func grab(in video: Video, from: Duration, to: Duration, period: Int = 5, completion: @escaping (Result<(URL, Int),Error>) -> Void) {
        guard let exportDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(.failure(VideoServiceError.exportDirectory))
            return
        }
        
        let urlRelativeString = video.url.absoluteString
        var urlImage = exportDirectory
        urlImage.append(path: video.grabName)
        urlImage.appendPathExtension("%d") // Filename pattern  image.1.png, image.2.png, ...
        urlImage.appendPathExtension("jpg")
        let countImages = (to - from).seconds / Double(period)
        
        // ffmpeg -i /Users/denisdmitriev/Movies/FarAway.mov -ss 51.9275129253125 -t 181.208333 -vf fps=1/5 -pix_fmt yuvj420p -q:v 7 /Users/denisdmitriev/Movies/FarAwayShort/image.%d.jpg
        let arguments = [
            "-loglevel", "error", // "warning",
            "-y",
            "-ss", "\(from.seconds)",
            "-i", "'\(urlRelativeString)'",
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
    
    /// Создание очереди скриншотов из видео.
    /// - Warning: Долго работает.
    static func grabNew(in video: Video, period: Double, from: Duration, to: Duration, quality: Double, callBackProgress: @escaping ((URL, Progress, Duration) -> Void), completion: @escaping (Result<URL,Error>) -> Void) {
        guard let exportDirectory = video.exportDirectory else {
            completion(.failure(VideoServiceError.exportDirectory))
            return
        }
        
        let urlAbsoluteString = video.url.absoluteString
        var urlImage = exportDirectory
        urlImage.append(path: video.grabName)
        urlImage.appendPathExtension("%d") // Filename pattern  image.1.png, image.2.png, ...
        let imageExtension = "jpg"
        urlImage.appendPathExtension(imageExtension)
        let countImages = (to - from).seconds / Double(period)
        
        let qualityReduced = (100 - quality).rounded() / 10
        
        // ffmpeg -i input.mp4 -vf "select='not(mod(t,5))'" -vsync vfr output_%04d.jpg
        // ffmpeg -i /Users/denisdmitriev/Movies/FarAway.mov -ss 51.9275129253125 -t 181.208333 -vf fps=1/5 -pix_fmt yuvj420p -q:v 7 /Users/denisdmitriev/Movies/FarAwayShort/image.%d.jpg
        // ffmpeg -i /Users/denisdmitriev/Movies/FarAway.mov -vf "select='not(mod(t,5))',setpts=N/FRAME_RATE/TB" /Users/denisdmitriev/Movies/FarAway/FarAway.%d.jpg
        let arguments = [
            "-loglevel", "error", // "warning",
            "-progress - -stats", // statistic callback
            "-y", //Overwrite output files without asking
            "-ss", "\(from.seconds + 1/video.frameRate + period/2)",
            "-i", "'\(urlAbsoluteString)'",
            "-to", "\(to.seconds)",
            "-vf", "fps=1/\(period)", //Set the number of video frames to output  1/5 every 5 seconds
//            "-vsync", "0", // if you want to keep every frame as-is with no drops or dupes
//            "-vf", "\"select=1/\(period),setpts=N/FRAME_RATE/TB\"",
            "-pix_fmt", "yuv420p", //Set pixel format
            "-q:v", "\(qualityReduced)",
            "'\(urlImage.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        FFmpegKit.executeAsync(command, withCompleteCallback: { session in
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
                let error = VideoServiceError.cut(video: video)
                completion(.failure(error))
            }
        }, withLogCallback: { _ in
            // add log callback
        }, withStatisticsCallback: { statistics in
            let indexImage = statistics?.getVideoFrameNumber() ?? .zero
            let mseconds = statistics?.getTime()
            guard let mseconds, indexImage != .zero else { return }
            let progress = Progress(value: Int(indexImage), total: Int(countImages))
            let currentUrlImage = urlImage
                .deletingPathExtension() // delete extension
                .deletingPathExtension() // delete pattern
                .appendingPathExtension("\(indexImage)") // add counter
                .appendingPathExtension(imageExtension) // return extension image
            
            let timecode = Duration.seconds(mseconds * period / 10e3)
            
            callBackProgress(currentUrlImage, progress, timecode)
        }, onDispatchQueue: .global(qos: .userInitiated))
    }
    
    /// Обрезание видео по точкам входа и выхода.
    /// Для скорости кодек экспорта как у исходного файла.
    /// Контейнер используется Quicktime.
    /// - Parameters:
    ///   - video: Video которое поддеживается FFmpeg.
    ///   - from: `Duration` точки начала для отрывка видео.
    ///   - to: `Duration` точка конца для отрывка видео.
    /// - Returns: 
    /// - callBackProgress: `Progress` кодирования.
    /// - completion: `URL` полученного отрывка видео.
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
            "-ss", "\(from.seconds)",
            "-to", "\(to.seconds)",
            "-i", "'\(urlRelativeString)'",
            
            "-c:v", "copy", // commands copy the original video without re-encoding
            "-c:a", "copy", // commands copy the original audio without re-encoding
            "'\(urlVideo.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        FFmpegKit.executeAsync(command, withCompleteCallback: { session in
            guard let state = session?.getState() else { return }
            switch state {
            case .running:
                print("🏁")
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
    
    /// Создание обложки для видео в низком разрешении в папку кеша для временного хранения.
    /// Выберает один из наиболее репрезентативных кадров в последовательности из 100 последовательных кадров.
    /// http://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video
    /// Command FFmpeg
    /// ```
    /// ffmpeg -i input.mov -vf thumbnail=n=100 thumb%04d.png
    /// ```
    /// - Returns: URL thumbnail from cache directory..
    static func thumbnail(for video: Video, completion: @escaping ((Result<URL, Error>) -> Void)) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(.failure(VideoServiceError.cacheDirectory))
            return
        }
        
        let thumbnailName = video.title + ".thumbnail" + ".jpeg"
        let urlImage = cachesDirectory.appendingPathComponent(thumbnailName)
        
        guard !FileManager.default.fileExists(atPath: urlImage.path) else {
            completion(.success(urlImage))
            return
        }

        let arguments: [String] = [
            "-loglevel", "quiet", // "warning",
            "-y",
            "-i", "'\(video.url.absoluteString)'",
            "-vf", "thumbnail=n=100,scale=320:320:force_original_aspect_ratio=decrease", // Pick one of the most representative frames in sequences of 100 consecutive frames/
//            "scale=320:320:force_original_aspect_ratio=decrease",
            "'\(urlImage.relativePath)'"
        ]
        let command = arguments.joined(separator: " ")
        
        let session = FFmpegKit.execute(command)
        guard let state = session?.getState() else { return }
        switch state {
        case .completed:
            completion(.success(urlImage))
        default:
            let error = VideoServiceError.commandFailure
            completion(.failure(error))
        }
    }
    
    /// Создание обложки для видео в низком разрешении в папку кеша для временного хранения асинхронно.
    /// Выберает один из наиболее репрезентативных кадров в последовательности из 100 последовательных кадров.
    ///
    /// Command FFmpeg
    /// ```
    /// ffmpeg -i input.mov -vf thumbnail=n=100 thumb%04d.png
    /// ```
    /// - Returns: URL thumbnail from cache directory..
    static func thumbnail(for video: Video) async throws -> URL {
        try await withUnsafeThrowingContinuation { continuation in
            thumbnail(for: video) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Получение длительности видео файла из метаданных.
    /// - Parameters:
    ///   - video: Video которое поддеживается FFmpeg.
    /// - Returns: TimeInterval в секундах.
    /// - Warning: Есть вероятность что вернется длительность равная нулю или null.
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
    
    /// Получение метаданных видео.
    ///
    /// Команда для FFmpeg
    /// ```
    /// ffprobe -loglevel error -show_entries stream_tags:format_tags -of json video.mov
    /// ```
    ///
    /// - Parameters:
    ///   - video: Video которое поддеживается FFmpeg.
    /// - Returns: struct `MetadataVideo` with format and streams.
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
    
    /// Получение длительности видео файла из метаданных асинхронно.
    /// - Parameters:
    ///   - video: Video которое поддеживается FFmpeg.
    /// - Returns: TimeInterval в секундах.
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
    
    /// Создание кеша для видео
    /// Для скорости копирование происходит в исходном кодеке
    /// - Parameters:
    ///   - video: Video которое не поддерживается AVFoundation.
    /// - Returns: URL файла из папки кеша приложения.
    /// - Warning: Нужно самостоятельно контролировать очищение файлов которые добавились в кеш.
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

extension FFmpegVideoService {
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
}

extension FFmpegVideoService {
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

extension FFmpegVideoService {
    struct Progress {
        let value: Int
        let total: Int
        
        var percent: Double {
            (Double(value) / Double(total)).round(to: 3)
        }
    }
}
