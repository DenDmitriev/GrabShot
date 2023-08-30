//
//  ImageSidebar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageSidebar: View {
    
    @ObservedObject var viewModel: ImageSidebarModel
    @State private var selectedItemID: ImageStrip.ID?
    @State private var hasImages = false
    @State private var showFileExporter = false
    
    var body: some View {
        
        NavigationSplitView {
            List(viewModel.imageStore.imageStrips, selection: $selectedItemID) { item in
                ImageItem(nsImage: item.nsImage, title: item.title)
            }
            .navigationTitle("Images")
            
            if hasImages {
                Button {
                    showFileExporter.toggle()
                } label: {
                    Text("Export all")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        } detail: {
            if let selectedItemID,
               let imageStrip = viewModel.imageStore.imageStrip(id: selectedItemID),
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
            if let selectedItem = selectedItemID {
                viewModel.delete(id: selectedItem)
                self.selectedItemID = nil
            }
        }
        .onReceive(viewModel.imageStore.$imageStrips, perform: { imageStrips in
            hasImages = !imageStrips.isEmpty
        })
        .onReceive(viewModel.$hasDropped, perform: { hasDropped in
            selectedItemID = hasDropped?.id
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
    }
}

struct ImageSidebar_Previews: PreviewProvider {
    static var previews: some View {
        ImageSidebar(viewModel: ImageSidebarModel())
    }
}
