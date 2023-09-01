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
    
    var dropDelegate: ImageDropDelegate
    @Published var imageStripViewModels: [ImageStripViewModel] = []
    
    @AppStorage(UserDefaultsService.Keys.stripImageHeight)
    private var stripImageHeight: Double = Grid.pt64
    
    @AppStorage(UserDefaultsService.Keys.colorImageCount)
    private var colorImageCount: Int = 8
    
    private var store = Set<AnyCancellable>()
    
    init() {
        dropDelegate = ImageDropDelegate()
        imageStore = ImageStore()
        imageRenderService = ImageRenderService()
        dropDelegate.imageHandler = self
        dropDelegate.dropAnimator = self
        bindImageStore()
        bindErrorImageRenderService()
    }
    
    func delete(id: ImageStrip.ID) {
        guard
            let indexStore = imageStore.imageStrips.firstIndex(where: { $0.id == id }),
            let indexModel = imageStripViewModels.firstIndex(where: { $0.imageStrip.id == id })
        else { return }
        DispatchQueue.main.async {
            self.imageStripViewModels.remove(at: indexModel)
            self.imageStore.imageStrips.remove(at: indexStore)
        }
    }
    
    func bindImageStore() {
        imageStore.$imageStrips
            .sink { [ weak self] imageStrips in
                imageStrips.forEach { imageStrip in
                    self?.imageStripViewModels.append(ImageStripViewModel(imageStrip: imageStrip))
                }
            }
            .store(in: &store)
    }
    
    func bindErrorImageRenderService() {
        imageRenderService.$error
            .sink { error in
                if let error {
                    self.error(error)
                }
            }
            .store(in: &store)
    }
    
    func getImageStripViewModel(by imageStrip: ImageStrip) -> ImageStripViewModel? {
        let model = imageStripViewModels.first(where: { $0.imageStrip == imageStrip })
        return model
    }
    
    func exportAll(result: Result<URL, Error>) {
        switch result {
        case .success(let directory):
            let gotAccess = directory.startAccessingSecurityScopedResource()
            if !gotAccess {
                let error = ImageStripError.exportDirectory(title: directory.relativePath)
                self.error(error)
                return
            }
            
            imageStripViewModels.forEach { viewModel in
                let url = directory.appendingPathComponent(viewModel.imageStrip.exportTitle, conformingTo: .image)
                viewModel.setExportURL(imageStrip: viewModel.imageStrip, url: url)
            }
            
            let imageStrips = imageStore.imageStrips
            imageRenderService.export(imageStrips: imageStrips, stripHeight: stripImageHeight, colorsCount: colorImageCount)
            
        case .failure(let failure):
            self.error(failure)
        }
    }
    
    private func error(_ error: Error) {
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

extension ImageSidebarModel: ImageHandler {
    func addImage(nsImage: NSImage, url: URL) {
        DispatchQueue.main.async {
            let imageStrip = ImageStrip(nsImage: nsImage, url: url)
            self.imageStore.imageStrips.append(imageStrip)
            self.hasDropped = self.imageStore.imageStrips.last
        }
    }
}

extension ImageSidebarModel: DropAnimator {
    func animate(is animate: Bool) {
        guard isAnimate != animate else { return }
        DispatchQueue.main.async {
            self.showDropZone = animate
            self.isAnimate = animate
        }
    }
}
