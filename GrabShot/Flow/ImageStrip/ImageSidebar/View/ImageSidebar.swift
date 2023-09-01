//
//  ImageSidebar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageSidebar: View {
    
    @ObservedObject var viewModel: ImageSidebarModel
    @State private var selectedItemIds: Set<ImageStrip.ID> = []
    @State private var hasImages = false
    @State private var showFileExporter = false
    @State private var current: Int = .zero
    @State private var total: Int = .zero
    @State private var isRendering: Bool = false
    
    var body: some View {
        
        NavigationSplitView {
            List(viewModel.imageStore.imageStrips, selection: $selectedItemIds) { item in
                ImageItem(nsImage: item.nsImage, title: item.title)
            }
            .navigationTitle("Images")
            .overlay {
                if isRendering {
                    ZStack {
                        Rectangle()
                            .fill(.black.opacity(0.75))
                        
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
               let imageStrip = viewModel.imageStore.imageStrip(id: selectedLastId),
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
            viewModel.delete(ids: selectedItemIds)
            self.selectedItemIds.removeAll()
        }
        .onReceive(viewModel.imageStore.$imageStrips, perform: { imageStrips in
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
            viewModel.exportAll(result: result)
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
}

struct ImageSidebar_Previews: PreviewProvider {
    static var previews: some View {
        ImageSidebar(viewModel: ImageSidebarModel())
    }
}
