//
//  VideoGrabSidebar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import SwiftUI

struct VideoGrabSidebar: View {
    @ObservedObject var viewModel: VideoGrabSidebarModel
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var coordinator: GrabCoordinator
    @State private var isProgress: Bool = false
    @State private var selection = Set<Video.ID>()
    @State private var selectedVideo: Video?
    @State private var hasVideo = false
    @State private var showFileExporter = false
    
    var body: some View {
        NavigationSplitView {
            List(videoStore.videos, selection: $selection) { video in
                VideoGrabItem(video: video, viewModel: viewModel, selection: $selection)
                    .contextMenu {
                        ItemVideoContextMenu(video: video, selection: $selection)
                    }
            }
            .contextMenu { VideosContextMenu(selection: $selection) }
            .navigationTitle("Video pool")
            .disabled(isProgress)
        } detail: {
            if selection.first != nil, let selectedVideo {
                if selectedVideo.duration == .zero {
                    ProgressView()
                } else {
                    VideoGrabView(video: selectedVideo, viewModel: .build(store: videoStore, score: coordinator.scoreController, coordinator: coordinator), isProgress: $isProgress)
                        .environment(\.isProgress, $isProgress)
                }
            } else if hasVideo {
                Text("Select video")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.light)
            } else {
                DropZoneView(
                    isAnimate: $viewModel.isAnimate,
                    showDropZone: $viewModel.showDropZone,
                    mode: .video
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(AppGrid.pt6)
                .contextMenu { VideosContextMenu(selection: $selection) }
            }
        }
        .onChange(of: selection) { newSelection in
            selectedVideo = videoStore[newSelection.first]
        }
        .onDrop(of: FileService.utTypes, delegate: viewModel.dropDelegate ?? VideoDropDelegate(store: videoStore))
        .onChange(of: isProgress) { newIsProgress in
            if videoStore.isProgress != newIsProgress {
                videoStore.isProgress = newIsProgress
            }
        }
    }
}

#Preview {
    let videoStore: VideoStore = {
        let store = VideoStore()
        store.addVideo(video: .placeholder)
        return store
    }()
    let imageStore = ImageStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: scoreController)
    let viewModel: VideoGrabSidebarModel = .build(store: videoStore, score: scoreController, coordinator: coordinator)
    
    struct PreviewWrapper: View {
        @StateObject var viewModel: VideoGrabSidebarModel
        @StateObject var videoStore: VideoStore
        
        var body: some View {
            VideoGrabSidebar(viewModel: viewModel)
                .environmentObject(videoStore)
                .environmentObject(viewModel)
        }
    }
    
    return PreviewWrapper(viewModel: viewModel, videoStore: videoStore)
}
