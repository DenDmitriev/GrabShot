//
//  ImageSidebarModelBuilder.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2023.
//

import Foundation

class ImageSidebarModelBuilder {
    static func build(store: ImageStore, score: ScoreController, coordinator: ImageStripCoordinator? = nil) -> ImageSidebarModel {
        let dropDelegate = ImageDropDelegate()
        let imageRenderService = ImageRenderService()
        let stripDropHandler = StripDropHandler()
        dropDelegate.stripDropHandler = stripDropHandler
        
        let viewModel = ImageSidebarModel(
            store: store,
            score: score,
            dropDelegate: dropDelegate,
            imageRenderService: imageRenderService
        )
        
        viewModel.coordinator = coordinator
        dropDelegate.stripDropHandler?.viewModel = viewModel
        
        return viewModel
    }
}
