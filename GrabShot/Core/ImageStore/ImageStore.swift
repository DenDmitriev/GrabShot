//
//  ImageStore.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageStore: ObservableObject {
    @Published var imageStrips: [ImageStrip] = []
    
    static let shared = ImageStore()
    
    private init() {}
    
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
                do {
                    let data = try Data(contentsOf: url)
                    guard let nsImage = NSImage(data: data) else { return }
                    let imageStrip = ImageStrip(nsImage: nsImage, url: url)
                    DispatchQueue.main.async {
                        self.insertImage(imageStrip)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
