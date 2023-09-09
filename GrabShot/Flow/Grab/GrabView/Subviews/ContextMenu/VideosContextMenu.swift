//
//  VideosContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct VideosContextMenu: View {
    
    @EnvironmentObject var grabModel: GrabModel
    @EnvironmentObject var videoStore: VideoStore
    @Binding var selection: Set<Video.ID>
    
    var body: some View {
        Button("Clear", role: .destructive) {
            let ids = videoStore.videos.map({ $0.id })
            deleteAction(ids: Set(ids))
        }
        .disabled(videoStore.videos.isEmpty)
    }
    
    private func deleteAction(ids: Set<Video.ID>) {
        withAnimation {
            grabModel.didDeleteVideos(by: ids)
            ids.forEach { id in
                selection.remove(id)
            }
        }
    }
}
