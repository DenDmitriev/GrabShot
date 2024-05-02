//
//  VideoGrabSidebar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import SwiftUI

struct VideoGrabNavigationView: View {
    @EnvironmentObject var viewModel: VideoGrabSidebarModel
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var coordinator: GrabCoordinator
    @EnvironmentObject var tabCoordinator: TabCoordinator

    @State private var selectedVideo: Video?
    @State private var hasVideo = false
    @State private var showFileExporter = false
    
    var body: some View {
        VStack {
            if viewModel.selection.first != nil, let selectedVideo {
                if selectedVideo.duration == .zero {
                    ProgressView()
                } else {
                    VideoGrabView(video: selectedVideo, viewModel: .build(store: videoStore, score: coordinator.scoreController, coordinator: coordinator), isProgress: $viewModel.isProgress)
                        .environment(\.isProgress, $viewModel.isProgress)
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
                .onAppear {
                    print(viewModel.selection)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(AppGrid.pt6)
                .contextMenu { VideosContextMenu(selection: $viewModel.selection) }
            }
        }
        .onReceive(videoStore.$addedVideo, perform: { newAddedVideo in
            if let id = newAddedVideo?.id {
                viewModel.selection = [id]
            }
        })
        .onReceive(tabCoordinator.$route, perform: { route in
            if route == .videoGrab { selectedVideo = videoStore.videos.last }
        })
        .onChange(of: viewModel.selection) { newSelection in
            selectedVideo = videoStore[newSelection.first]
        }
        .onDrop(of: FileService.utTypes, delegate: viewModel.dropDelegate ?? VideoDropDelegate(store: videoStore))
        .onChange(of: viewModel.isProgress) { newIsProgress in
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
        @StateObject var coordinator: GrabCoordinator
        @StateObject var viewModel: VideoGrabSidebarModel
        @StateObject var videoStore: VideoStore
        
        var body: some View {
            VideoGrabNavigationView()
                .environmentObject(videoStore)
                .environmentObject(viewModel)
                .environmentObject(coordinator)
        }
    }
    
    return PreviewWrapper(coordinator: coordinator, viewModel: viewModel, videoStore: videoStore)
}
