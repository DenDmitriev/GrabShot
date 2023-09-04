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
    private var stripImageHeight: Double = Grid.pt64
    
    @AppStorage(UserDefaultsService.Keys.colorImageCount)
    private var colorImageCount: Int = 8
    
    init(imageStrip: ImageStrip, error: ImageStripError? = nil) {
        self.imageStrip = imageStrip
        self.error = error
    }
    
    @MainActor
    func export(imageStrip: ImageStrip) {
        let imageService = ImageRenderService()
        imageService.export(imageStrips: [imageStrip], stripHeight: stripImageHeight, colorsCount: colorImageCount)
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
    
    func fetchColors(count: Int) {
        guard let cgImage = imageStrip.nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        do {
            let cgColors = try ColorsExtractorService.extract(from: cgImage, mood: .dominationColor(formula: .CIE76), count: count)
            let colors = cgColors.map({ Color(cgColor: $0) })
            DispatchQueue.main.async {
                self.imageStrip.colors = colors
            }
        } catch let error {
            self.error(error)
        }
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
