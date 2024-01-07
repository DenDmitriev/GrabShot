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
    @AppStorage(DefaultsKeys.stripViewMode) private var stripMode: StripMode = .liner
    @State var heightTimeline: CGFloat = AppGrid.pt72
    @State private var progress: Int = .zero
    @State private var total: Int = 1
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
                TimelineView(video: video, currentRange: $currentRange, playhead: $playhead, heightTimeline: $heightTimeline)
                    .onAppear {
                        switch video.range {
                        case .full:
                            currentRange = .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration)))
                        case .excerpt:
                            currentRange = video.rangeTimecode ?? .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration)))
                        }
                    }
                
                VStack {
                    // Progress
                    HStack {
                        ProgressColorView(progress: $progress, total: $total, colors: $video.grabColors, stripMode: stripMode)
                            .onReceive(video.progress.$total) { total in
                                self.total = total
                            }
                            .onReceive(video.progress.$current) { progress in
                                self.progress = progress
                            }
                        
                        Button {
                            if !video.grabColors.isEmpty {
                                coordinator.present(sheet: .colorStrip(colors: video.grabColors))
                            }
                        } label: {
                            Image(systemName: "barcode")
                        }
                        .disabled(video.grabColors.isEmpty)
                    }
                    
                    // Controls
                    GrabControlView(video: video, viewModel: viewModel)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, alignment: .trailing)
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
