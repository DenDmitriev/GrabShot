//
//  VideoService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 20.11.2022.
//

import Cocoa
import AVFoundation

class VideoService {
    
    let fileService: FileService
    
    init() {
        fileService = FileService.shared
    }
    
    //убрать Bool из completion
    func grab(in video: Video, timecode: TimeInterval, quality: Double, completion: @escaping ((Bool, URL?, Error?) -> Void)) {
        
        //print(video.url.absoluteString)
        if timecode == 0.0 {
            fileService.makeDir(for: video.url)
        }

        let urlExport = video.url.deletingPathExtension()
        let urlRelativeString = video.url.relativePath
        let timecodeFormatted = self.timecodeString(for: timecode)
        let urlImage = urlExport.appendingPathComponent(video.title).appendingPathExtension(timecodeFormatted).appendingPathExtension("jpg")
        let qualityReduced = (100 - quality).rounded() / 10

        guard let launchPath = Bundle.main.path(forResource: "ffmpeg", ofType: "") else { return }

        let task = Process()
        task.launchPath = launchPath
        task.arguments = [
            "-y", //Overwrite output files without asking
            "-ss", "\(timecode)",
            "-i", urlRelativeString,
            "-vframes", "1", //Set the number of video frames to output
            "-q:v", "\(qualityReduced)",
            urlImage.relativePath
        ]
        do {
            try task.run()
            task.waitUntilExit()
            completion(true, urlImage, nil)
        } catch {
            completion(false, nil, error)
        }
    }
    /*
    func grabAV(in video: Video, timecode: TimeInterval, quality: Double, completion: @escaping ((Bool, URL?, Error?) -> Void)) async {
        let avVideo = AVURLAsset(url: video.url, options: [:])
        let assetImgGenerate = AVAssetImageGenerator(asset: avVideo)
        assetImgGenerate.appliesPreferredTrackTransform = true

        let urlExport = video.url.deletingPathExtension()
        let timecodeFormatted = timecodeString(for: timecode)
        let urlImage = urlExport.appendingPathExtension(timecodeFormatted).appendingPathExtension("png")
        
        do {
            let videoDuration: CMTime = try await avVideo.load(.duration)
            let timescale = videoDuration.timescale
            let grabTime = CMTime(seconds: 2, preferredTimescale: timescale)
            let cgImage = try assetImgGenerate.copyCGImage(at: grabTime, actualTime: nil)
            //may be use another func
            //assetImgGenerate.generateCGImagesAsynchronously(forTimes: [grabTime], completionHandler: nil)
            try fileService.writeImage(cgImage: cgImage, to: urlImage, format: .jpeg) //add menu for choose format
            completion(true, urlImage, nil)
        } catch {
            completion(false, nil, error)
        }
    }
    */
    
    func calculate(for value: Video.Value, videos: [Video], period: Int, completion: @escaping (() -> Void)) {
        switch value {
        case .all, .duration:
            duration(for: videos)
            completion()
        case .shots:
            updateShotsCount(for: videos, with: period)
            completion()
        }
    }
    
    //MARK: - Private
    
    private func duration(for videos: [Video]) {
        videos.forEach { video in
            guard
                video.duration == 0,
                let launchPath = Bundle.main.path(forResource: "ffprobe", ofType: "")
            else { return }
            
            let task = Process()
            task.launchPath = launchPath
            task.arguments = [
                "-i", video.url.relativePath,
                "-show_entries", "format=duration",
                //"stream=width,height", //resolution
                "-v", "quiet",
                "-of", "csv=p=0"
            ]
            let outputPipe = Pipe()
            task.standardOutput = outputPipe
            
            do {
                try task.run()
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(decoding: outputData, as: UTF8.self)
                task.waitUntilExit()
                
                let duration = (output as NSString).doubleValue
                let durationString = DateComponentsFormatter().string(from: duration) ?? "N/A"
                video.duration = duration
                video.durationString = durationString
                video.shots = self.shotsCount(for: duration, with: Session.shared.period)
            } catch {
                print(error)
            }
        }
    }
    
    private func updateShotsCount(for videos: [Video], with period: Int) {
        videos.forEach { video in
            let shots = shotsCount(for: video.duration, with: period)
            video.shots = shots
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
    
    private func shotsCount(for duration: TimeInterval, with period: Int) -> Int {
        let shots = Int(duration.rounded(.up)) / period
        return shots
    }
}
