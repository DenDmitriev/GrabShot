//
//  ImageService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 31.08.2023.
//

import SwiftUI

class ImageRenderService: ObservableObject {
    
    @Published var error: ImageRenderServiceError?
    @Published var progress: Progress = .init(total: .zero)
    @Published var isRendering: Bool = false
    
    let operationQueue: OperationQueue = {
       let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .utility
        return operationQueue
    }()
    
    // MARK: - Functions
    
    func export(imageStrips: [ImageStrip], stripHeight: CGFloat, colorsCount: Int) {
        configureProgress(total: imageStrips.index(before: imageStrips.count))
        renderingStatus(is: true)
        imageStrips.forEach { imageStrip in
            addMergeOperation(imageStrip: imageStrip, stripHeight: stripHeight, colorsCount: colorsCount)
        }
    }
    
    func stop() {
        operationQueue.cancelAllOperations()
        progress = .init(total: .zero)
        renderingStatus(is: false)
    }
    
    // MARK: - Private functions
    
    private func renderingStatus(is rendering: Bool) {
        DispatchQueue.main.async {
            self.isRendering = rendering
        }
    }
    
    private func addMergeOperation(imageStrip: ImageStrip, stripHeight: CGFloat, colorsCount: Int) {
        guard
            let nsImage = imageStrip.nsImage(),
            let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let exportURL = imageStrip.exportURL
        else { return }
        
        let mergeOperation = ImageMergeOperation(
            colors: imageStrip.colors,
            cgImage: cgImage,
            stripHeight: stripHeight,
            colorsCount: colorsCount,
            colorMood: imageStrip.colorMood
        )
        
        mergeOperation.completionBlock = { [weak self] in
            self?.hasResult(result: mergeOperation.result, exportURL: exportURL)
            self?.pushProgress()
        }
        
        operationQueue.addOperation(mergeOperation)
    }
    
    private func hasResult(result: Result<Data, Error>?, exportURL: URL) {
        switch result {
        case .success(let data):
            do {
                try self.save(jpeg: data, to: exportURL)
            } catch let error {
                hasError(error: error)
            }
        case .failure(let error):
            hasError(error: error)
        case .none:
            hasError(error: ImageRenderServiceError.mergeImageWithStrip)
        }
    }
    
    private func configureProgress(total: Int) {
        DispatchQueue.main.async {
            self.progress.total = total
        }
    }
    
    private func pushProgress() {
        DispatchQueue.main.async {
            self.progress.current += 1
        }
        
        if progress.current >= progress.total {
            renderingStatus(is: false)
        }
    }
    
    private func save(jpeg data: Data, to url: URL) throws {
        try FileService.shared.writeImage(jpeg: data, to: url)
        url.stopAccessingSecurityScopedResource()
    }
    
    private func hasError(error: Error) {
        guard let error = error as? LocalizedError else { return }
        DispatchQueue.main.async {
            self.error = ImageRenderServiceError.map(
                errorDescription: error.localizedDescription,
                recoverySuggestion: error.recoverySuggestion
            )
        }
    }
}
