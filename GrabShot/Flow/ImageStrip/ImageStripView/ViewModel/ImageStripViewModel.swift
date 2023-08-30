//
//  ImageStripViewModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageStripViewModel: ObservableObject {
    
    @Published var imageStrip: ImageStrip
    
    @Published var error: ImageStripError?
    @Published var showAlert: Bool = false
    
    @AppStorage(UserDefaultsService.Keys.stripImageHeight)
    private var stripImageHeight: Double = Grid.pt32
    
    @AppStorage(UserDefaultsService.Keys.colorImageCount)
    private var colorImageCount: Int = 8
    
    init(imageStrip: ImageStrip, error: ImageStripError? = nil) {
        self.imageStrip = imageStrip
        self.error = error
    }
    
    @MainActor
    func export(imageStrip: ImageStrip) {
        let size = imageStrip.nsImage.size
        let view = StripPalleteView(colors: .constant(imageStrip.colors), showPickers: false)
            .frame(width: size.width, height: stripImageHeight)
        
        guard let stripCGImage = ImageRenderer(content: view).cgImage else { return }
        guard let shotCGImage = imageStrip.nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        guard let jpegData = ImagerCreator.merge(image: shotCGImage, with: stripCGImage) else { return }
        
        guard let exportURL = imageStrip.exportURL else { return }
        
        do {
            try FileService.shared.writeImage(jpeg: jpegData, to: exportURL)
            exportURL.stopAccessingSecurityScopedResource()
        } catch let error {
            self.error(error)
        }
    }
    
    func prepareDirectory(with result: Result<URL, Error>, for imageStrip: ImageStrip) {
        switch result {
        case .success(let url):
            if let oldExportURL = imageStrip.exportURL {
                oldExportURL.stopAccessingSecurityScopedResource()
            }
            let gotAccess = url.startAccessingSecurityScopedResource()
            if !gotAccess {
                let error = ImageStripError.exportDirectory(title: url.relativePath)
                self.error(error)
                return
            }
            
            setExportURL(imageStrip: imageStrip, url: url)
            
        case .failure(let failure):
            self.error(failure)
        }
    }
    
    func setExportURL(imageStrip: ImageStrip, url: URL) {
        imageStrip.exportURL = url
    }
    
    func colors(nsImage: NSImage, count: Int) -> [Color] {
        let colors = StripManagerImage.getAverageColors(nsImage: nsImage, colorCount: count)
        return colors ?? []
    }
    
    private func error(_ error: Error) {
        DispatchQueue.main.async {
            if let localizedError = error as? LocalizedError {
                self.error = ImageStripError.map(
                    errorDescription: localizedError.localizedDescription,
                    recoverySuggestion: localizedError.recoverySuggestion
                )
            } else {
                self.error = ImageStripError.unknown
            }
            self.showAlert = true
        }
    }
}
