//
//  VideosContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct VideosContextMenu: View {
    
    @EnvironmentObject var coordinator: GrabCoordinator
    @EnvironmentObject var videoStore: VideoStore
    @Binding var selection: Set<Video.ID>
    
    var body: some View {
        VStack {
            Button("Import Videos") {
                coordinator.showFileImporter()
            }
            
            Divider()
            
            Button("Clear", role: .destructive) {
                let ids = videoStore.videos.map({ $0.id })
                deleteAction(ids: Set(ids))
            }
            .disabled(videoStore.videos.isEmpty)
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
}

#Preview {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: scoreController)
    
    return VideosContextMenu(selection: .constant(Set<Video.ID>()))
        .environmentObject(videoStore)
        .environmentObject(coordinator)
}
