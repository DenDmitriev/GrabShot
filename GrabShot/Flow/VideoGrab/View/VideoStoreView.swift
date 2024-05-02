//
//  VideoStoreView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 02.05.2024.
//

import SwiftUI

struct VideoStoreView: View {
    @EnvironmentObject var viewModel: VideoGrabSidebarModel
    @EnvironmentObject var videoStore: VideoStore
    
    var body: some View {
        List(videoStore.videos, selection: $viewModel.selection) { video in
            VideoGrabItem(video: video, viewModel: viewModel, selection: $viewModel.selection)
                .contextMenu {
                    ItemVideoContextMenu(video: video, selection: $viewModel.selection)
                }
        }
        .contextMenu { VideosContextMenu(selection: $viewModel.selection) }
        .navigationTitle("Video pool")
        .disabled(viewModel.isProgress)
    }
}

#Preview {
    let store = VideoStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let viewModel = VideoGrabSidebarModel.build(store: store, score: scoreController)
    
    return VideoStoreView()
        .environmentObject(viewModel)
        .environmentObject(store)
}
