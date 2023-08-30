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
    @Published var error: ImageStripError?
    @Published var showAlert: Bool = false
    @Published var hasDropped: ImageStrip?
    
    var dropDelegate: ImageDropDelegate
    @Published var imageStripViewModels: [ImageStripViewModel] = []
    
    private var store = Set<AnyCancellable>()
    
    init() {
        dropDelegate = ImageDropDelegate()
        imageStore = ImageStore()
        dropDelegate.imageHandler = self
        bindImageStore()
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
            .sink { imageStrips in
                imageStrips.forEach { imageStrip in
                    self.imageStripViewModels.append(ImageStripViewModel(imageStrip: imageStrip))
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
                viewModel.export(imageStrip: viewModel.imageStrip)
            }
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
