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
    @Binding var isProgress: Bool
    @State private var playhead: Duration = .zero
    @State private var gesturePlayhead: Duration = .zero
    @State private var exportPanel: VideoExportTab = .grab
    
    var body: some View {
        VSplitView {
            HSplitView {
                // Playback
                PlaybackPlayer(video: video, playhead: $playhead, gesturePlayhead: $gesturePlayhead, viewModel: .build(playhead: $playhead, coordinator: coordinator))
                    .onReceive(viewModel.$currentTimecode) { timecode in
                        playhead = timecode
                    }
                    .frame(minHeight: AppGrid.pt300)
                    .layoutPriority(1)
                
                // Property Panel
                VStack(spacing: .zero) {
                    ExportTabbar(tab: $exportPanel)
                        .disabled(viewModel.isProgress)
                    SeparatorLine()
                    
                    ExportPropertyView(video: video)
                        .disabled(viewModel.isProgress)
                    SeparatorLine()
                    
                    ExportSettingsView(video: video, exportPanel: $exportPanel)
                        .disabled(viewModel.isProgress)
                    SeparatorLine()
                    
                    ExportControl(video: video, exportPanel: $exportPanel)
                        .environmentObject(viewModel)
                }
                .frame(minWidth: AppGrid.pt300)
                .layoutPriority(0)
            }
            
            // Timeline
            TimelineVideoView(video: video, playhead: $playhead) { newPlayhead in
                gesturePlayhead = newPlayhead
            }
            .frame(maxHeight: AppGrid.pt200)
        }
        .onReceive(viewModel.$isProgress, perform: { isProgress in
            self.isProgress = isProgress
        })
    }
}

#Preview {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let score = ScoreController(caretaker: Caretaker())
    let viewModel: VideoGrabViewModel = .build(store: videoStore, score: score)
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: score)
    
    return VideoGrabView(video: .placeholder, viewModel: .build(store: videoStore, score: score), isProgress: .constant(false))
        .environmentObject(viewModel)
        .environmentObject(coordinator)
        .frame(width: 700, height: 500)
}

