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
    private var stripImageHeight: Double = Grid.pt64
    
    @AppStorage(DefaultsKeys.colorImageCount)
    private var colorImageCount: Int = 8
    
    private let imageService = ImageRenderService()
    
    init(imageStrip: ImageStrip, error: ImageStripError? = nil) {
        self.imageStrip = imageStrip
        self.error = error
    }
    
    @MainActor
    func export(imageStrip: ImageStrip) {
        imageService.export(imageStrips: [imageStrip], stripHeight: stripImageHeight, colorsCount: colorImageCount)
        ImageStore.shared.currentColorExtractCount += 1
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
    
    func fetchColors(method: ColorExtractMethod? = nil, count: Int? = nil, formula: DeltaEFormula? = nil, flags: [DominantColors.Flag] = []) async {
        guard
            let nsImage = await imageStrip.nsImage(),
            let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return }
        let method = await method != nil ? method : imageStrip.colorMood.method
        let formula = await formula != nil ? formula : imageStrip.colorMood.formula
        let count = count ?? colorImageCount
        let flags = await flags.isEmpty ? imageStrip.colorMood.flags : flags
        
        guard
            let method = method,
            let formula = formula
        else { return }
        
        do {
            let cgColors = try await ColorsExtractorService.extract(from: cgImage, method: method, count: count, formula: formula, flags: flags)
            let colors = cgColors.map({ Color(cgColor: $0) })
            DispatchQueue.main.async {
                self.imageStrip.colors = colors
            }
        } catch let error {
            self.error(error)
        }
    }
    
    func fetchColorWithFlags(isExcludeBlack: Bool, isExcludeWhite: Bool) async {
        var flags = [DominantColors.Flag]()
        if isExcludeBlack {
            flags.append(.excludeBlack)
        }
        if isExcludeWhite {
            flags.append(.excludeWhite)
        }
        await fetchColors(flags: flags)
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
