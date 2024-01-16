//
//  VideoGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI

struct VideoGrabView: View {
    
    @EnvironmentObject var coordinator: GrabCoordinator
    @ObservedObject var video: Video
    @StateObject var viewModel: VideoGrabViewModel
    @State private var playhead: Duration = .zero
    @State private var playbackSize: CGSize = .zero
    @State private var propertyPanel: PropertyPanel = .instruments
    
    var body: some View {
        VSplitView {
            HSplitView {
                // Playback
                let playbackViewModel: PlaybackPlayerModel = .build(playhead: $playhead, coordinator: coordinator)
                PlaybackPlayer(video: video, playhead: $playhead, viewModel: playbackViewModel)
                    .onReceive(viewModel.$currentTimecode) { timecode in
                        playhead = timecode
                    }
                    .frame(idealWidth: playbackSize.width)
                    .layoutPriority(1)
                
                // Property Panel
                VStack(spacing: .zero) {
                    Picker("", selection: $propertyPanel) {
                        PropertyPanel.instruments.label
                            .tag(PropertyPanel.instruments)
                        PropertyPanel.metadata.label
                            .tag(PropertyPanel.metadata)
                    }
                    .pickerStyle(.segmented)
                    .padding([.horizontal, .top])
                    
                    
                    switch propertyPanel {
                    case .instruments:
                        // Export settings
                        GrabPropertyView(video: video)
                            .tag(PropertyPanel.instruments)
                    case .metadata:
                        MetadataVideoView(metadata: $video.metadata)
                            .tag(PropertyPanel.metadata)
                    }
                }
                .frame(minWidth: AppGrid.pt300)
                .layoutPriority(0)
                
            }
            .readSize { size in
                let playbackWidth = (video.aspectRatio ?? 16 / 9) * size.height
                playbackSize = .init(width: playbackWidth, height: size.height)
            }
//            .layoutPriority(1)
            
            // Timeline
            VStack {
                TimelineView(video: video, playhead: $playhead)
                
                VStack(spacing: AppGrid.pt16) {
                    // Progress
                    GrabProgressPanel(video: video)
                    
                    // Controls
                    GrabControlView(video: video, viewModel: viewModel)
                        .padding(.bottom)
                }
                .padding(.vertical, AppGrid.pt8)
                .padding(.horizontal)
            }
//            .layoutPriority(0)
        }
    }
}

#Preview {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let score = ScoreController(caretaker: Caretaker())
    let viewModel: VideoGrabViewModel = .build(store: videoStore, score: score)
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: score)
    
    return VideoGrabView(video: .placeholder, viewModel: viewModel)
        .environmentObject(viewModel)
        .environmentObject(coordinator)
        .frame(width: 700, height: 500)
}

extension VideoGrabView {
    enum PropertyPanel {
        case instruments, metadata
        
        var label: some View {
            switch self {
            case .instruments:
                Label("Instruments", systemImage: "slider.horizontal.3")
            case .metadata:
                Label("Metadata", systemImage: "list.bullet.clipboard")
            }
        }
    }
}
