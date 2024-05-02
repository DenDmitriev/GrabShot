//
//  ImageSidebarModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageSidebarModel: ObservableObject {
    
    weak var coordinator: ImageStripCoordinator?
    @ObservedObject var imageStore: ImageStore
    @ObservedObject var imageRenderService: ImageRenderService
    @Published var error: ImageStripError?
    @Published var showAlert: Bool = false
    
    @Published var isAnimate: Bool = false
    @Published var showDropZone: Bool = false
    
    
    // new
    @Published var selectedItemIds = Set<ImageStrip.ID>()
    @Published var export: ExportImages = .selected
    @Published var hasImages = false
    @Published var showFileExporter = false
    @Published var isRendering: Bool = false
    
    var scoreController: ScoreController
    var dropDelegate: ImageDropDelegateProtocol
    
    @AppStorage(DefaultsKeys.stripImageHeight)
    private var stripImageHeight: Double = AppGrid.pt64
    
    @AppStorage(DefaultsKeys.colorImageCount)
    private var colorImageCount: Int = 8
    
    @AppStorage(DefaultsKeys.createStripBorder)
    private var createStripBorder: Bool = false
    
    @AppStorage(DefaultsKeys.stripBorderWidth)
    private var stripBorderWidth: Int = 5
    
    @AppStorage(DefaultsKeys.stripBorderColor)
    private var stripBorderColor: Color = .white
    
    init(
        store: ImageStore,
        score: ScoreController,
        dropDelegate: ImageDropDelegateProtocol,
        imageRenderService: ImageRenderService
    ) {
        imageStore = store
        scoreController = score
        self.dropDelegate = dropDelegate
        self.imageRenderService = imageRenderService
    }
    
    func delete(ids: Set<ImageStrip.ID>) {
        ids.forEach { id in
            DispatchQueue.main.async {
                guard
                    let indexStore = self.imageStore.imageStrips.firstIndex(where: { $0.id == id })
                else { return }
                self.imageStore.imageStrips.remove(at: indexStore)
            }
        }
    }
    
    func export(result: Result<URL, Error>, imageIds: Set<ImageStrip.ID>) {
        switch result {
        case .success(let directory):
            guard directory.startAccessingSecurityScopedResource() else {
                let error = ImageStripError.exportDirectory(title: directory.relativePath)
                presentError(error)
                return
            }
            
            let imageStrips = imageIds.compactMap({ imageStore[$0] })
            
            imageStrips.forEach { imageStrip in
                let url = directory.appendingPathComponent(imageStrip.exportTitle, conformingTo: .image)
                imageStrip.exportURL = url
            }
            
            let border = createStripBorder ? stripBorderWidth : nil
            let borderColor = createStripBorder ? stripBorderColor.cgColor : nil
            imageRenderService.export(imageStrips: imageStrips, stripHeight: stripImageHeight, colorsCount: colorImageCount, border: border, borderColor: borderColor)
            
            scoreController.updateColorScore(count: imageStrips.count)
            
        case .failure(let failure):
            presentError(failure)
        }
    }
    
    func presentError(_ error: Error) {
        DispatchQueue.main.async {
            if let localizedError = error as? LocalizedError {
                self.error = ImageStripError.map(
                    errorDescription: localizedError.localizedDescription,
                    recoverySuggestion: localizedError.recoverySuggestion
                )
            } else {
                self.error = ImageStripError.unknown
            }
            self.showAlert = true
        }
    }
}

extension ImageSidebarModel: StripDropHandlerOutput {}
