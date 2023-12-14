//
//  ItemContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct ItemVideoContextMenu: View {
    
    enum URLType {
        case file, directory
    }
    
    var video: Video
    
    @Binding var selection: Set<Video.ID>
    @EnvironmentObject var videosModel: VideosModel
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var imageStore: ImageStore
    @Environment(\.openWindow) var openWindow
    @FocusedBinding(\.showRangePicker) private var showRangePicker
    
    var body: some View {
        Button(video.isEnable ? "Disable" : "Enable") {
            toggle(video: video)
        }
        
        Button("Grabbing range") {
            videoStore.contextVideo = video.id
            showRangePicker = true
        }
        .disabled(showRangePicker == nil)
        
        Divider()
        
        Button("Import grabbed shots") {
            importGrabbedShots(video: video)
        }
        .disabled(video.images.isEmpty)
        
        Divider()
        
        Button("Metadata") {
            showVideoProperties()
        }
        .disabled(video.metadata == nil)
        
        Divider()
        
        Button("Show in Finder", action: { showInFinder(url: video.url, type: .file) })
        
        Button("Show export directory", action: { showInFinder(url: video.exportDirectory, type: .directory) })
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
    
    private func showInFinder(url: URL?, type: URLType) {
        guard
            let url
        else { return }
        switch type {
        case .directory:
            FileService.openDirectory(by: url)
        case .file:
            FileService.openFile(for: url)
        }
    }
    
    private func deleteAction(ids: Set<Video.ID>) {
        withAnimation {
            videoStore.deleteVideos(by: ids) {
                ids.forEach { id in
                    selection.remove(id)
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
    
    private func showVideoProperties() {
        if let metadata = video.metadata {
            openWindow(id: WindowId.metadata.id, value: metadata)
        }
    }
}

#Preview("Context Menu") {
    ItemVideoContextMenu(video: .placeholder, selection: .constant([]))
        .environmentObject(VideosModel())
        .environmentObject(VideoStore())
        .environmentObject(ImageStore())
}
