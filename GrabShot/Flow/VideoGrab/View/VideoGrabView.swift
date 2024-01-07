//
//  VideoGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI

struct VideoGrabView: View {
    
    @EnvironmentObject var coordinator: GrabCoordinator
    @Binding var video: Video
    @State var currentRange: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .zero, upper: .zero))
    @StateObject var viewModel: VideoGrabViewModel
    @State private var playhead: Duration = .zero
    
    var body: some View {
        VSplitView {
            HSplitView {
                // Playback
                PlaybackView(video: video, playhead: $playhead)
                    .onReceive(viewModel.$currentTimecode) { timecode in
                        playhead = timecode
                    }
                
                // Export settings
                GrabPropertyView(video: video)
            }
            
            // Timeline
            VStack {
                TimelineView(video: video, currentRange: $currentRange, playhead: $playhead)
                
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
        }
    }
}

#Preview {
    let videoStore = VideoStore()
    let score = ScoreController(caretaker: Caretaker())
    let viewModel: VideoGrabViewModel = .build(store: videoStore, score: score)
    let coordinator = GrabCoordinator(videoStore: videoStore, scoreController: score)
    
    return VideoGrabView(video: .constant(.placeholder), viewModel: viewModel)
        .environmentObject(viewModel)
        .environmentObject(coordinator)
}
