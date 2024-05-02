//
//  ImageStore.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageStore: ObservableObject {
    @Published var imageStrips: [ImageStrip] = []
    @Published var currentColorExtractCount: Int = 0
    @Published var error: AppError?
    @Published var showAlert = false
    @Published var didAddImage = false
    @AppStorage(DefaultsKeys.colorExtractCount) var colorExtractCount: Int = 0
    
    private var backgroundGlobalQueue = DispatchQueue.global(qos: .background)
    
    init() {
        currentColorExtractCount = colorExtractCount
    }
    
    subscript(imageStripId: ImageStrip.ID?) -> ImageStrip {
        get {
            if let imageStrip = imageStrips.first(where: { $0.id == imageStripId }) {
                return imageStrip
            } else {
                return .placeholder
            }
        }
        
        set(newValue) {
            if let id = imageStripId,
                let index = imageStrips.firstIndex(where: { $0.id == id }) {
                imageStrips[index] = newValue
            }
        }
    }

    func insertImage(_ image: ImageStrip) {
        if !imageStrips.contains(where: { $0.url == image.url }) {
            imageStrips.append(image)
            didAddImage.toggle()
        }
    }
    
    func imageStrip(id: UUID?) -> ImageStrip? {
        imageStrips.first(where: { $0.id == id })
    }
    
    func insertImages(_ urls: [URL]) {
        DispatchQueue.global(qos: .utility).async {
            urls.forEach { url in
                let imageStrip = ImageStrip(url: url)
                DispatchQueue.main.async {
                    self.insertImage(imageStrip)
                }
            }
        }
    }
    
    func presentError(error: LocalizedError) {
        let error = AppError.map(errorDescription: error.errorDescription, failureReason: error.recoverySuggestion)
        DispatchQueue.main.async {
            self.error = error
            self.showAlert = true
        }
    }
}
