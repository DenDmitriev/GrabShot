//
//  ImageStore.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageStore: ObservableObject {
    @Published var imageStrips: [ImageStrip] = []
    
    func imageStrip(id: UUID?) -> ImageStrip? {
        imageStrips.first(where: { $0.id == id })
    }
}
