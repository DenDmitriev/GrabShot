//
//  ImageSidebar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStripNavigationView: View {
    
    @EnvironmentObject var viewModel: ImageSidebarModel
    @EnvironmentObject var imageStore: ImageStore
    @EnvironmentObject var coordinator: ImageStripCoordinator
    
    var body: some View {
        VStack {
            if let selectedLastId = viewModel.selectedItemIds.first {
                let imageStrip = imageStore[selectedLastId]
                let stripViewModel = ImageStripViewModel(imageStrip: imageStrip, imageRenderService: viewModel.imageRenderService)
                ImageStripView(colorMood: stripViewModel.imageStrip.colorMood)
                    .environmentObject(stripViewModel)
            } else if viewModel.hasImages {
                Text("Choose an image")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.light)
            } else {
                DropZoneView(isAnimate: $viewModel.isAnimate, showDropZone: $viewModel.showDropZone, mode: .image)
            }
        }
        .onDeleteCommand { delete(ids: viewModel.selectedItemIds) }
        .onReceive(imageStore.$imageStrips, perform: { imageStrips in
            viewModel.hasImages = !imageStrips.isEmpty
        })
        .onReceive(imageStore.$didAddImage, perform: { didAddImage in
            if let addedImageId = imageStore.imageStrips.last?.id {
                viewModel.selectedItemIds = [addedImageId]
            }
        })
        .onDrop(of: [.image], delegate: viewModel.dropDelegate)
        .fileExporter(
            isPresented: $viewModel.showFileExporter,
            document: ExportDirectory(title: "Export Images"),
            contentType: .directory,
            defaultFilename: "Export Images"
        ) { result in
            let imageIds: Set<ImageStrip.ID>
            switch viewModel.export {
            case .all:
                imageIds = Set(imageStore.imageStrips.map({ $0.id }))
            case .selected:
                imageIds = viewModel.selectedItemIds
            case .context(let id):
                imageIds = Set([id])
            }
            viewModel.export(result: result, imageIds: imageIds)
        }
        .onReceive(viewModel.$showAlert) { showAlert in
            if showAlert, let error = viewModel.error {
                coordinator.presentAlert(error: error)
                viewModel.showAlert = false
            }
        }
        .onReceive(viewModel.imageRenderService.$hasError) { hasError in
            if hasError, let error = viewModel.imageRenderService.error {
                coordinator.presentAlert(error: .map(
                    errorDescription: error.localizedDescription,
                    recoverySuggestion: error.recoverySuggestion)
                )
                viewModel.imageRenderService.hasError = false
            }
        }
        .onReceive(viewModel.imageRenderService.$isRendering) { isRendering in
            viewModel.isRendering = isRendering
        }
    }
    
    private func delete(ids: Set<ImageStrip.ID>) {
        withAnimation {
            viewModel.delete(ids: ids)
            ids.forEach { id in
                viewModel.selectedItemIds.remove(id)
            }
        }
    }
}

struct ImageSidebar_Previews: PreviewProvider {
    static var previews: some View {
        let store = ImageStore()
        let scoreController = ScoreController(caretaker: Caretaker())
        let coordinator = ImageStripCoordinator(imageStore: store, scoreController: scoreController)
        let viewModels = ImageSidebarModelBuilder.build(store: store, score: ScoreController(caretaker: Caretaker()))
        
        ImageStripNavigationView()
            .environmentObject(store)
            .environmentObject(coordinator)
            .environmentObject(viewModels)
    }
}
