//
//  VideoService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 20.11.2022.
//

import Cocoa
import AVFoundation
import ffmpegkit

class VideoService {
    
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
    
    //MARK: - Private
    
    static func duration(for video: Video, completion: @escaping ((Result<TimeInterval, Error>) -> Void)) {
        let path = video.url.relativePath
        let arguments = [
            "'\(path)'",
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
