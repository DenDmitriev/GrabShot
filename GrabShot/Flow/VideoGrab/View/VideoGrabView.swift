//
//  VideoGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//
// https://medium.com/@eastism/writer-1-how-to-use-splitview-swiftui-be5df89d3f78

import SwiftUI

struct VideoGrabView: View {
    
    @EnvironmentObject var coordinator: GrabCoordinator
    @ObservedObject var video: Video
    @StateObject var viewModel: VideoGrabViewModel
    @State private var playhead: Duration = .zero
    @State private var gesturePlayhead: Duration = .zero
    @State private var exportPanel: ExportPanel = .grab
    
    var body: some View {
        VSplitView {
            HSplitView {
                // Playback
                PlaybackPlayer(video: video, playhead: $playhead, gesturePlayhead: $gesturePlayhead, viewModel: .build(playhead: $playhead, coordinator: coordinator))
                    .onReceive(viewModel.$currentTimecode) { timecode in
                        playhead = timecode
                    }
                    .layoutPriority(1)
                
                // Property Panel
                VSplitView {
                    ExportPicker(panel: $exportPanel)
                    
                    ExportPropertyView(video: video)
                    
                    ExportSettingsView(video: video, exportPanel: $exportPanel)
                }
                .frame(minWidth: AppGrid.pt300)
                .layoutPriority(0)
            }
            .layoutPriority(1)
            
            // Timeline
            VStack {
                TimelineView(video: video, playhead: $playhead) { newPlayhead in
                    gesturePlayhead = newPlayhead
                }
                
                GrabExportPanel(video: video)
                    .environmentObject(viewModel)
            }
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
        .frame(width: 700, height: 600)
}

