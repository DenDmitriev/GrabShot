//
//  FileService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

#if os(macOS)
    import Cocoa
#endif

import UniformTypeIdentifiers

class FileService {
    
    static let shared = FileService()
    
    let ffmpegTypes = [
        "flv",
        "mkv",
        "ogg",
        "mxf",
        "3gp",
        "avi",
        "mov",
        "mp4",
        "mpg",
        "vob"
    ]
    
    var types: [String] {
        get {
            ffmpegTypes
        }
    }
    
    static let utTypes: [UTType] = [
        .movie,
        .video,
        .quickTimeMovie,
        .mpeg,
        .mpeg2Video,
        .mpeg4Movie,
        .appleProtectedMPEG4Video,
        .avi
    ]
    
    enum Format: String {
        case png, jpeg, tiff, heif
    }
    
    func isTypeVideoOk(_ url: URL) -> Result<Bool, DropError> {
        if FileService.shared.types.contains(url.pathExtension.lowercased()) {
            return .success(true)
        } else {
            let allowedTypes = FileService.shared.types.sorted().joined(separator: ", ")
            let error = DropError.file(path: url, allowedTypes: allowedTypes)
            return .failure(error)
        }
    }
    
    static func openDirectory(by url: URL) {
        guard url.isDirectory else { return }
        NSWorkspace.shared.open(url)
    }
    
    /// Create directory on disk
    static func makeDirectory(for urlVideo: URL) {
        let pathDir = urlVideo.deletingPathExtension().path
        if !FileManager.default.fileExists(atPath: pathDir) {
            do {
                try FileManager.default.createDirectory(atPath: pathDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static func openFile(for url: URL) {
        guard url.isFileURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// Write image file on disk
    func writeImage(cgImage: CGImage, to url: URL, format: Format) throws {
        let ciContext = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        let urlExport = url.appendingPathExtension(format.rawValue)
        guard let colorSpace = ciImage.colorSpace else { return }
        
        switch format {
        case .png:
            try ciContext.writePNGRepresentation(of: ciImage, to: urlExport, format: .RGBA8, colorSpace: colorSpace)
        case .jpeg:
            try ciContext.writeJPEGRepresentation(of: ciImage, to: urlExport, colorSpace: colorSpace)
        case .tiff:
            try ciContext.writeTIFFRepresentation(of: ciImage, to: urlExport, format: .BGRA8, colorSpace: colorSpace)
        case .heif:
            try ciContext.writeHEIFRepresentation(of: ciImage, to: urlExport, format: .RGBA8, colorSpace: colorSpace)
        }
    }
    
    func writeImage(jpeg data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
    
    /// Dialog for choose export directory
    static func chooseExportDirectory(completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.main.async {
            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = false
            openPanel.canCreateDirectories = true
            openPanel.level = .modalPanel
            openPanel.begin { response in
                switch response {
                case .OK:
                    if let directoryURL = openPanel.directoryURL {
                        completion(.success(directoryURL))
                    }
                default:
                    completion(.failure(VideoServiceError.exportDirectory))
                }
            }
        }
    }
    
    /// Clear all files in cache  folder of application
    static func clearCache(handler: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cachesDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            handler(.success(true))
        } catch {
            handler(.failure(error))
        }
    }
    
    /// Clear jpeg files in cache  folder of application
    static func clearJpegCache(handler: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cachesDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs where fileURL.pathExtension == "jpeg" {
                try FileManager.default.removeItem(at: fileURL)
            }
            handler(.success(true))
        } catch {
            handler(.failure(error))
        }
    }
    
    /// Clear video files in cache  folder of application
    static func clearVideoCache(handler: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cachesDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs where fileURL.pathExtension == "mov" {
                try FileManager.default.removeItem(at: fileURL)
            }
            handler(.success(true))
        } catch {
            handler(.failure(error))
        }
    }
    
    /// Get total size for all files in cache folder of application, in bytes
    static func getCacheSize() -> Int? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cachesDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            var totalSizeInBytes: Int = .zero
            for fileURL in fileURLs {
                let resources = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                guard let fileSize = resources.fileSize else { continue } // bytes
                totalSizeInBytes += fileSize
            }
            
            return totalSizeInBytes
        } catch {
            print(error)
            return nil
        }
    }
    
    /// Get total size for jpeg files in cache folder of application, in bytes
    static func getJpegCacheSize() -> Int? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cachesDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            var totalSizeInBytes: Int = .zero
            for fileURL in fileURLs where fileURL.pathExtension == "jpeg" {
                let resources = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                guard let fileSize = resources.fileSize else { continue } // bytes
                totalSizeInBytes += fileSize
            }
            
            return totalSizeInBytes
        } catch { 
            print(error)
            return nil
        }
    }
    
    /// Get total size for video files in cache folder of application, in bytes
    static func getVideoCacheSize() -> Int? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cachesDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            var totalSizeInBytes: Int = .zero
            for fileURL in fileURLs where fileURL.pathExtension == "mov" {
                let resources = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                guard let fileSize = resources.fileSize else { continue } // bytes
                totalSizeInBytes += fileSize
            }
            
            return totalSizeInBytes
        } catch {
            print(error)
            return nil
        }
    }
}
