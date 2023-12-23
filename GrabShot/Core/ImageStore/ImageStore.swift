//
//  ImageStore.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI
import Combine

class ImageStore: ObservableObject {
    @Published var imageStrips: [ImageStrip] = []
    @Published var currentColorExtractCount: Int = 0
    @Published var error: AppError?
    @Published var showAlert = false
    @AppStorage(DefaultsKeys.colorExtractCount) var colorExtractCount: Int = 0
    
    private var store = Set<AnyCancellable>()
    private var backgroundGlobalQueue = DispatchQueue.global(qos: .background)
    
    init() {
        currentColorExtractCount = colorExtractCount
    }

    func insertImage(_ image: ImageStrip) {
        if !imageStrips.contains(where: { $0.url == image.url }) {
            imageStrips.append(image)
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
}
