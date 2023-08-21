//
//  FileService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import Cocoa

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
    
    static func openDir(by path: URL) {
        NSWorkspace.shared.open(path)
    }
    
    static func makeDir(for urlVideo: URL) {
        let pathDir = urlVideo.deletingPathExtension().path
        if !FileManager.default.fileExists(atPath: pathDir) {
            do {
                try FileManager.default.createDirectory(atPath: pathDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func openFile(for url: URL) {
        guard url.isFileURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
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
}
