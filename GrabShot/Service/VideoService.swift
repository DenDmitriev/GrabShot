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
    
    let fileService: FileService
    
    init() {
        fileService = FileService.shared
    }
    
    func grab(in video: Video, timecode: TimeInterval, quality: Double, completion: @escaping ((Bool, URL?, Error?) -> Void)) {
        let urlRelativeString = video.url.relativePath
        let qualityReduced = (100 - quality).rounded() / 10
        let timecodeFormatted = self.timecodeString(for: timecode)
        let urlExport = video.url.deletingPathExtension()
        let urlImage = urlExport.appendingPathComponent(video.title)
            .appendingPathExtension(timecodeFormatted)
            .appendingPathExtension("jpg")
        
        let arguments = [
            "-y", //Overwrite output files without asking
            "-ss", "\(timecode)",
            "-i", urlRelativeString,
            "-vframes", "1", //Set the number of video frames to output
            "-q:v", "\(qualityReduced)",
            urlImage.relativePath
        ]
        let command = arguments.joined(separator: " ")
        FFmpegKit.executeAsync(command) { session in
            guard let state = session?.getState() else { return }
            switch state {
            case .completed:
                completion(true, urlImage, nil)
            default:
                return
            }
        }
    }
    
    func calculate(for value: Video.Value, videos: inout [Video], period: Int, completion: @escaping (() -> Void)) {
        switch value {
        case .all, .duration:
            duration(for: &videos)
            completion()
        case .shots:
            completion()
        }
    }
    
    //MARK: - Private
    
    private func duration(for videos: inout [Video]) {
        videos.forEach { video in
            guard
                video.duration == 0
            else { return }
            
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
                    video.duration = duration
                default:
                    return
                }
            }
        }
    }
    
    static func duration(for video: Video) async throws -> TimeInterval {
        let path = video.url.relativePath
        let arguments = [
            "'\(path)'",
            "-v", "quiet",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1"
        ]
        let command = arguments.joined(separator: " ")
        print(command)
        
        return try await withCheckedThrowingContinuation { continuation in
            FFprobeKit.executeAsync(command) { session in
                guard let state = session?.getState() else { return }
                switch state {
                case .completed:
                    guard let output = session?.getOutput() else { return }
                    let duration = (output as NSString).doubleValue
                    continuation.resume(with: .success(duration))
                default:
                    let error = VideoServiceError.duration(video: video)
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
    
    private func timecodeString(for timecode: TimeInterval) -> String {
        let formatter: DateComponentsFormatter = {
            let format = DateComponentsFormatter()
            format.allowedUnits = [.hour, .minute, .second]
            format.unitsStyle = .positional
            format.maximumUnitCount = 3
            return format
        }()
        return formatter.string(from: timecode) ?? String(timecode)
    }
}
