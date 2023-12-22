//
//  VideosContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct VideosContextMenu: View {
    
    @EnvironmentObject var videoStore: VideoStore
    @FocusedBinding(\.showVideoImporter) private var showVideoImporter
    @Binding var selection: Set<Video.ID>
    
    var body: some View {
        VStack {
            Button("Import Videos") {
                showVideoImporter = true
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
    VideosContextMenu(selection: .constant(Set<Video.ID>()))
        .environmentObject(VideoStore())
}
