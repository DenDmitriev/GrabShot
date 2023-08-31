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
    
    let operationQueue: OperationQueue = {
       let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .utility
        return operationQueue
    }()
    
    // MARK: - Functions
    
    func export(imageStrips: [ImageStrip], stripHeight: CGFloat, colorsCount: Int) {
        configureProgress(total: imageStrips.count)
        imageStrips.forEach { imageStrip in
            addMergeOperation(imageStrip: imageStrip, stripHeight: stripHeight, colorsCount: colorsCount)
        }
    }
    
    func stop() {
        operationQueue.cancelAllOperations()
        progress = .init(total: .zero)
    }
    
    // MARK: - Private functions
    
    private func addMergeOperation(imageStrip: ImageStrip, stripHeight: CGFloat, colorsCount: Int) {
        guard
            let cgImage = imageStrip.nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let exportURL = imageStrip.exportURL
        else { return }
        
        let mergeOperation = ImageMergeOperation(colors: imageStrip.colors, cgImage: cgImage, stripHeight: stripHeight, colorsCount: colorsCount)
        
        mergeOperation.completionBlock = {
            self.hasResult(result: mergeOperation.result, exportURL: exportURL)
            self.pushProgress()
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
