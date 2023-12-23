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
//    @FocusedBinding(\.showVideoImporter) private var showVideoImporter
    @Binding var selection: Set<Video.ID>
    
    var body: some View {
        VStack {
            Button("Import Videos") {
                coordinator.showFileImporter()
//                showVideoImporter = true
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
                    selection.remove(id)
                }
            }
        }
    }
}

#Preview {
    let videoStore = VideoStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let coordinator = GrabCoordinator(videoStore: videoStore, scoreController: scoreController)
    
    return VideosContextMenu(selection: .constant(Set<Video.ID>()))
        .environmentObject(videoStore)
        .environmentObject(coordinator)
}
