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
    @State private var current: Int = .zero
    @State private var total: Int = .zero
    @State private var isRendering: Bool = false
    @State private var export: Export = .selected
    
    var body: some View {
        NavigationSplitView {
            List(imageStore.imageStrips, selection: $selectedItemIds) { item in
                ImageItem(nsImage: item.nsImage, title: item.title)
                    .contextMenu {
                        Button("Show in Finder", action: { showInFinder(url: item.url) })
                        
                        Button("Export selected") {
                            if !selectedItemIds.contains(item.id) {
                                export = .context(id: item.id)
                                showFileExporter.toggle()
                            } else {
                                export = .selected
                                showFileExporter.toggle()
                            }
                        }
                        
                        Button("Delete", role: .destructive) {
                            if !selectedItemIds.contains(item.id) {
                                delete(ids: [item.id])
                            } else {
                                delete(ids: selectedItemIds)
                            }
                        }
                    }
            }
            .contextMenu {
                Button("Clear") {
                    let ids = imageStore.imageStrips.map({ $0.id })
                    delete(ids: Set(ids))
                }
                .disabled(imageStore.imageStrips.isEmpty)
            }
            .navigationTitle("Images")
            .overlay {
                if isRendering {
                    ZStack {
                        Color.clear
                            .background(.ultraThinMaterial)
                        
                        ProgressView(
                            value: Double(current),
                            total: Double(total)
                        )
                        .progressViewStyle(BagelProgressStyle())
                        .onReceive(viewModel.imageRenderService.progress.$total) { total in
                            self.total = total
                        }
                        .onReceive(viewModel.imageRenderService.progress.$current) { current in
                            self.current = current
                        }
                        .frame(maxWidth: Grid.pt64, maxHeight: Grid.pt64)
                    }
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
                ZStack {
                    DropImageIcon()
                    
                    DropZoneView(isAnimate: $viewModel.isAnimate, showDropZone: $viewModel.showDropZone)
                }
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
    
    private func showInFinder(url: URL?) {
        guard let url else { return }
        FileService.openFile(for: url)
    }
}

struct ImageSidebar_Previews: PreviewProvider {
    static var previews: some View {
        ImageSidebar(viewModel: ImageSidebarModel())
            .environmentObject(ImageStore.shared)
    }
}
