//
//  ItemContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct ItemVideoContextMenu: View {
    
    @ObservedObject var video: Video
    @Binding var selection: Set<Video.ID>
    @EnvironmentObject var coordinator: GrabCoordinator
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var imageStore: ImageStore
    
    var body: some View {
        Button(video.isEnable ? "Disable" : "Enable") {
            toggle(video: video)
        }
        
        Divider()
        
        Button("Import grabbed shots") {
            importGrabbedShots(video: video)
        }
        .disabled(video.images.isEmpty)
        
        Divider()
        
        Button("Show metadata") {
            coordinator.openWindow(metadata: video.metadata)
        }
        .disabled(video.metadata == nil)
        
        Button("Show in Finder") {
            coordinator.openFile(by: video.url)
        }
        
        Button("Show export directory") {
            if let url = video.exportDirectory { coordinator.openFolder(by: url) }
        }
        .disabled(video.exportDirectory == nil)
        
        Divider()
        
        Button("Delete", role: .destructive) {
            if !selection.contains(video.id) {
                deleteAction(ids: [video.id])
            } else {
                deleteAction(ids: selection)
            }
        }
    }
    
    private func deleteAction(ids: Set<Video.ID>) {
        withAnimation {
            videoStore.deleteVideos(by: ids) {
                ids.forEach { id in
                    DispatchQueue.main.async {
                        selection.remove(id)
                    }
                }
            }
        }
    }
    
    private func importGrabbedShots(video: Video) {
        let urls = video.images
        imageStore.insertImages(urls)
    }
    
    private func toggle(video: Video) {
        video.isEnable.toggle()
    }
}

#Preview("Context Menu") {
    ItemVideoContextMenu(video: .placeholder, selection: .constant([]))
        .environmentObject(VideosModel())
        .environmentObject(VideoStore())
        .environmentObject(ImageStore())
}
