//
//  ImageDropDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI
import UniformTypeIdentifiers

protocol ImageDropDelegateProtocol: AnyObject, DropDelegate {
    var stripDropHandler: StripDropHandler? { get set }
}

class ImageDropDelegate: ImageDropDelegateProtocol {
    
    var stripDropHandler: StripDropHandler?
    
    func dropEntered(info: DropInfo) {
        stripDropHandler?.animate(is: true)
    }
    
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
                    self?.stripDropHandler?.addImage(nsImage: nsImage, url: url)
                }
            }
        }
        
        return true
    }
    
    func dropExited(info: DropInfo) {
        stripDropHandler?.animate(is: false)
    }
    
}
