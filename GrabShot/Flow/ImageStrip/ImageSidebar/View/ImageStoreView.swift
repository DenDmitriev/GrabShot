//
//  ImageStoreView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 02.05.2024.
//

import SwiftUI

struct ImageStoreView: View {
    @EnvironmentObject var viewModel: ImageSidebarModel
    @EnvironmentObject var imageStore: ImageStore
    
    var body: some View {
        VStack {
            List(imageStore.imageStrips, selection: $viewModel.selectedItemIds) { item in
                ImageItem(url: item.url, title: item.title)
                    .contextMenu {
                        ImageItemContextMenu(selectedItemIds: $viewModel.selectedItemIds, export: $viewModel.export, showFileExporter: $viewModel.showFileExporter)
                            .environmentObject(item)
                            .environmentObject(viewModel)
                    }
            }
            .contextMenu {
                ImageSidebarContextMenu(selectedItemIds: $viewModel.selectedItemIds)
                    .environmentObject(imageStore)
                    .environmentObject(viewModel)
            }
            .navigationTitle("Images")
            .overlay {
                if viewModel.isRendering {
                    ImageSidebarProgressView()
                        .environmentObject(viewModel)
                }
            }
            
            if viewModel.hasImages {
                Button {
                    viewModel.export = .all
                    viewModel.showFileExporter.toggle()
                } label: {
                    Text("Export all")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .disabled(viewModel.isRendering)
            }
        }
    }
}

#Preview {
    let store = ImageStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let viewModel = ImageSidebarModelBuilder.build(store: store, score: ScoreController(caretaker: Caretaker()))
    
    return ImageStoreView()
        .environmentObject(store)
        .environmentObject(viewModel)
}
