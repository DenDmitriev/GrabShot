//
//  ImageDropDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI
import UniformTypeIdentifiers

class ImageDropDelegate: DropDelegate {
    
    weak var errorHandler: DropErrorHandler?
    weak var dropAnimator: DropAnimator?
    weak var imageHandler: ImageHandler?
    
    func performDrop(info: DropInfo) -> Bool {
        let infoURL = info.itemProviders(for: [.fileURL])
        let infoImage = info.itemProviders(for: [.image])
        
        infoURL.enumerated().forEach { [weak self] index, itemProvider in
            itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                guard
                    let data = data,
                    let url = URL(dataRepresentation: data, relativeTo: nil)
                else {
                    return
                }
                
                infoImage[index].loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                    guard
                        let data = data,
                        let nsImage = NSImage(data: data)
                    else {
                        return
                    }
                    self?.imageHandler?.addImage(nsImage: nsImage, url: url)
                }
            }
        }
        
        return true
    }
}
