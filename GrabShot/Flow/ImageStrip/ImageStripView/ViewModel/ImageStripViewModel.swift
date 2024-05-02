//
//  ImageStripViewModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI
import DominantColors

class ImageStripViewModel: ObservableObject {
    
    @Published var imageStrip: ImageStrip
    
    @Published var error: ImageStripError?
    @Published var showAlert: Bool = false
    
    @AppStorage(DefaultsKeys.stripImageHeight)
    private var stripImageHeight: Double = AppGrid.pt64
    
    @AppStorage(DefaultsKeys.colorImageCount)
    private var colorImageCount: Int = 8
    
    @AppStorage(DefaultsKeys.createStripBorder)
    private var createStripBorder: Bool = false
    
    @AppStorage(DefaultsKeys.stripBorderWidth)
    private var stripBorderWidth: Int = 5
    
    @AppStorage(DefaultsKeys.stripBorderColor)
    private var stripBorderColor: Color = .white
    
    let imageService: ImageRenderService
    
    init(imageStrip: ImageStrip, imageRenderService: ImageRenderService, error: ImageStripError? = nil) {
        self.imageStrip = imageStrip
        self.imageService = imageRenderService
        self.error = error
    }
    
    @MainActor
    func export(imageStrip: ImageStrip) {
        let border = createStripBorder ? stripBorderWidth : nil
        let borderColor = createStripBorder ? stripBorderColor.cgColor : nil
        imageService.export(imageStrips: [imageStrip], stripHeight: stripImageHeight, colorsCount: colorImageCount, border: border, borderColor: borderColor)
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
    
    func aspectRatio() -> Double {
        let size = imageStrip.size
        if size.width != 0, size.height != 0 {
            return size.width / size.height
        } else {
            return 16 / 9
        }
    }
    
    func fetchColors(method: ColorExtractMethod? = nil, count: Int? = nil, formula: DeltaEFormula? = nil, quality: DominantColorQuality? = nil, options: [DominantColors.Options] = []) {
        guard
            let nsImage = imageStrip.nsImage(),
            let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return }
        let method = method != nil ? method : imageStrip.colorMood.method
        let formula = formula != nil ? formula : imageStrip.colorMood.formula
        let quality = quality ?? imageStrip.colorMood.quality
        let count = count ?? colorImageCount
        let options = options.isEmpty ? imageStrip.colorMood.options : options
        
        guard
            let method = method,
            let formula = formula
        else { return }
        
        Task {
            do {
                let cgColors = try await ColorsExtractorService.extract(from: cgImage, method: method, count: count, formula: formula, quality: quality, options: options)
                let colors = cgColors.map({ Color(cgColor: $0) })
                DispatchQueue.main.async {
                    self.imageStrip.colors = colors
                }
            } catch let error {
                self.error(error)
            }
        }
    }
    
    func fetchColorWithFlags(isExcludeBlack: Bool, isExcludeWhite: Bool, isExcludeGray: Bool) {
        var options = [DominantColors.Options]()
        if isExcludeBlack {
            options.append(.excludeBlack)
        }
        if isExcludeWhite {
            options.append(.excludeWhite)
        }
        if isExcludeGray {
            options.append(.excludeGray)
        }
        fetchColors(options: options)
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
