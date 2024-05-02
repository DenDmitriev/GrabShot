//
//  ImageSidebar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageSidebar: View {
    
    @ObservedObject var viewModel: ImageSidebarModel
    @EnvironmentObject var imageStore: ImageStore
    @EnvironmentObject var coordinator: ImageStripCoordinator
    @State private var selectedItemIds = Set<ImageStrip.ID>()
    @State private var hasImages = false
    @State private var showFileExporter = false
    @State private var isRendering: Bool = false
    @State private var export: ExportImages = .selected
    
    var body: some View {
        NavigationSplitView {
            List(imageStore.imageStrips, selection: $selectedItemIds) { item in
                ImageItem(url: item.url, title: item.title)
                    .contextMenu {
                        ImageItemContextMenu(selectedItemIds: $selectedItemIds, export: $export, showFileExporter: $showFileExporter)
                            .environmentObject(item)
                            .environmentObject(viewModel)
                    }
            }
            .contextMenu {
                ImageSidebarContextMenu(selectedItemIds: $selectedItemIds)
                    .environmentObject(imageStore)
                    .environmentObject(viewModel)
            }
            .navigationTitle("Images")
            .overlay {
                if isRendering {
                    ImageSidebarProgressView()
                        .environmentObject(viewModel)
                }
            }
            
            if hasImages {
                VStack {
                    Button {
                        export = .all
                        showFileExporter.toggle()
                    } label: {
                        Text("Export all")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .disabled(isRendering)
                }
                
            }
        } detail: {
            if let selectedLastId = selectedItemIds.first {
                let imageStrip = imageStore[selectedLastId]
                let stripViewModel = ImageStripViewModel(imageStrip: imageStrip, imageRenderService: viewModel.imageRenderService)
                ImageStripView(viewModel: stripViewModel)
            } else if hasImages {
                Text("Choose an image")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.light)
            } else {
                DropZoneView(isAnimate: $viewModel.isAnimate, showDropZone: $viewModel.showDropZone, mode: .image)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onDeleteCommand { delete(ids: selectedItemIds) }
        .onReceive(imageStore.$imageStrips, perform: { imageStrips in
            hasImages = !imageStrips.isEmpty
        })
        .onReceive(imageStore.$didAddImage, perform: { didAddImage in
            if let addedImageId = imageStore.imageStrips.last?.id {
                selectedItemIds.insert(addedImageId)
            }
        })
        .onDrop(of: [.image], delegate: viewModel.dropDelegate)
        .fileExporter(
            isPresented: $showFileExporter,
            document: ExportDirectory(title: "Export Images"),
            contentType: .directory,
            defaultFilename: "Export Images"
        ) { result in
            let imageIds: Set<ImageStrip.ID>
            switch export {
            case .all:
                imageIds = Set(imageStore.imageStrips.map({ $0.id }))
            case .selected:
                imageIds = selectedItemIds
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
            self.isRendering = isRendering
        }
    }
    
    private func delete(ids: Set<ImageStrip.ID>) {
        withAnimation {
            viewModel.delete(ids: ids)
            ids.forEach { id in
                selectedItemIds.remove(id)
            }
        }
    }
}

struct ImageSidebar_Previews: PreviewProvider {
    static var previews: some View {
        let store = ImageStore()
        let scoreController = ScoreController(caretaker: Caretaker())
        let coordinator = ImageStripCoordinator(imageStore: store, scoreController: scoreController)
        
        ImageSidebar(viewModel: ImageSidebarModelBuilder.build(store: store, score: ScoreController(caretaker: Caretaker())))
            .environmentObject(store)
            .environmentObject(coordinator)
    }
}
