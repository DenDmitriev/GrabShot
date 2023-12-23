//
//  ImageSidebarModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI
import Combine

class ImageSidebarModel: ObservableObject {
    
    @ObservedObject var imageStore: ImageStore
    @ObservedObject var imageRenderService: ImageRenderService
    @Published var error: ImageStripError?
    @Published var showAlert: Bool = false
    @Published var hasDropped: ImageStrip?
    
    @Published var isAnimate: Bool = false
    @Published var showDropZone: Bool = false
    
    var scoreController: ScoreController
    var dropDelegate: ImageDropDelegateProtocol
    var imageStripViewModels: [ImageStripViewModel] = []
    
    @AppStorage(DefaultsKeys.stripImageHeight)
    private var stripImageHeight: Double = AppGrid.pt64
    
    @AppStorage(DefaultsKeys.colorImageCount)
    private var colorImageCount: Int = 8
    
    private var store = Set<AnyCancellable>()
    
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
        
        bindImageStore()
        bindErrorImageRenderService()
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
    
    func bindImageStore() {
        imageStore.$imageStrips
            .sink { [weak self] imageStrips in
                guard let self = self else { return }
                
                var willDeletedViewModels: [ImageStripViewModel] = []
                self.imageStripViewModels.forEach { viewModel in
                    if !imageStrips.contains(viewModel.imageStrip) {
                        willDeletedViewModels.append(viewModel)
                    }
                }
                
                willDeletedViewModels.forEach { viewModel in
                    self.imageStripViewModels.removeAll(where: { $0.imageStrip == viewModel.imageStrip })
                }
                
                var willCreatedImageStrips: [ImageStrip] = []
                imageStrips.forEach { imageStrip in
                    if !self.imageStripViewModels.contains(where: { $0.imageStrip == imageStrip }) {
                        willCreatedImageStrips.append(imageStrip)
                    }
                }
                
                let imageStripViewModels = willCreatedImageStrips.map { imageStrip -> ImageStripViewModel in
                    return ImageStripViewModel(store: self.imageStore, imageStrip: imageStrip)
                }
                self.imageStripViewModels.append(contentsOf: imageStripViewModels)
            }
            .store(in: &store)
    }
    
    func bindErrorImageRenderService() {
        imageRenderService.$error
            .sink { [weak self] error in
                if let error {
                    self?.presentError(error)
                }
            }
            .store(in: &store)
    }
    
    func getImageStripViewModel(by imageStrip: ImageStrip) -> ImageStripViewModel? {
        let model = imageStripViewModels.first(where: { $0.imageStrip == imageStrip })
        return model
    }
    
    func export(for export: ExportImages, result: Result<URL, Error>, imageIds: Set<ImageStrip.ID>?) {
        switch result {
        case .success(let directory):
            let gotAccess = directory.startAccessingSecurityScopedResource()
            if !gotAccess {
                let error = ImageStripError.exportDirectory(title: directory.relativePath)
                self.presentError(error)
                return
            }
            
            imageStripViewModels.forEach { viewModel in
                let url = directory.appendingPathComponent(viewModel.imageStrip.exportTitle, conformingTo: .image)
                viewModel.setExportURL(imageStrip: viewModel.imageStrip, url: url)
            }
            
            var imageStrips = [ImageStrip]()
            
            switch export {
            case .all:
                imageStrips = imageStore.imageStrips
            case .selected:
                imageStrips = imageIds?.compactMap({ id in
                    imageStore.imageStrips.first(where: { $0.id == id })
                }) ?? []
            case .context(let id):
                if let imageStrip = imageStore.imageStrips.first(where: { $0.id == id }) {
                    imageStrips = [imageStrip]
                }
            }
            
            imageRenderService.export(imageStrips: imageStrips, stripHeight: stripImageHeight, colorsCount: colorImageCount)
            
            scoreController.updateColorScore(count: imageStrips.count)
            
        case .failure(let failure):
            self.presentError(failure)
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
