//
//  StripDropHandler.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2023.
//

import Cocoa

protocol StripDropHandlerOutput: AnyObject {
    var imageStore: ImageStore { get set }
    var hasDropped: ImageStrip? { get set }
    var showDropZone: Bool { get set }
    var isAnimate: Bool { get set }
    
    func presentError(_ error: Error)
}

class StripDropHandler {
    weak var viewModel: StripDropHandlerOutput?
    
    func addImage(nsImage: NSImage, url: URL) {
        DispatchQueue.main.async {
            let imageStrip = ImageStrip(url: url)
            self.viewModel?.imageStore.insertImage(imageStrip)
            self.viewModel?.hasDropped = self.viewModel?.imageStore.imageStrips.last
        }
    }
    func animate(is animate: Bool) {
        guard viewModel?.isAnimate != animate else { return }
        DispatchQueue.main.async {
            self.viewModel?.showDropZone = animate
            self.viewModel?.isAnimate = animate
        }
    }
}
