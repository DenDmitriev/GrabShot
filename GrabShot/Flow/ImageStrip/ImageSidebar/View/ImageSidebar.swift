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
    @State private var selectedItemIds = Set<ImageStrip.ID>()
    @State private var hasImages = false
    @State private var showFileExporter = false
    @State private var isRendering: Bool = false
    @State private var export: Export = .selected
    
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
            if let selectedLastId = selectedItemIds.first,
               let imageStrip = imageStore.imageStrip(id: selectedLastId),
               let stripViewModel = viewModel.getImageStripViewModel(by: imageStrip)
            {
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
        .onDeleteCommand {
            delete(ids: selectedItemIds)
        }
        .onReceive(imageStore.$imageStrips, perform: { imageStrips in
            hasImages = !imageStrips.isEmpty
        })
        .onReceive(viewModel.$hasDropped, perform: { hasDropped in
//            if let hasDropped {
//                selectedItemID.insert(hasDropped.id)
//            }
        })
        .onDrop(of: [.image], delegate: viewModel.dropDelegate)
        .fileExporter(
            isPresented: $showFileExporter,
            document: ExportDirectory(title: "Export Images"),
            contentType: .directory,
            defaultFilename: "Export Images"
        ) { result in
            viewModel.export(for: export, result: result, imageIds: selectedItemIds)
        }
        .alert(isPresented: $viewModel.showAlert, error: viewModel.error) { localizedError in
            Text(localizedError.localizedDescription)
        } message: { localizedError in
            Text(localizedError.recoverySuggestion ?? "")
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
        ImageSidebar(viewModel: ImageSidebarModel(store: store, score: ScoreController(caretaker: Caretaker())))
            .environmentObject(store)
    }
}
