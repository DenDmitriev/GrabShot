//
//  ImageSidebarModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageSidebarModel: ObservableObject {
    var dropDelegate: ImageDropDelegate
    @ObservedObject var imageStore: ImageStore
    
    init() {
        dropDelegate = ImageDropDelegate()
        imageStore = ImageStore()
        dropDelegate.imageHandler = self
    }
}

extension ImageSidebarModel: ImageHandler {
    func addImage(nsImage: NSImage) {
        DispatchQueue.main.async {
            self.imageStore.nsImages.append(nsImage)
        }
    }
}
