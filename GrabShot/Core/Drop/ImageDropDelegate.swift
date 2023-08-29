//
//  ImageDropDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageDropDelegate: DropDelegate {
    
    weak var errorHandler: DropErrorHandler?
    weak var dropAnimator: DropAnimator?
    weak var imageHandler: ImageHandler?
    
    func performDrop(info: DropInfo) -> Bool {
        info.itemProviders(for: [.image]).forEach { [weak self] itemProvider in
            itemProvider.loadDataRepresentation(forTypeIdentifier: "public.image") { data, error in
                guard
                    let data = data,
                    let nsImage = NSImage(data: data),
                    let url = URL(dataRepresentation: data, relativeTo: nil)
                else {
                    return
                }
                self?.imageHandler?.addImage(nsImage: nsImage)
            }
        }

        return true
    }
}
