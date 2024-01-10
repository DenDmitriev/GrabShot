//
//  TimelineView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.01.2024.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var video: Video
    @Binding var currentRange: ClosedRange<Duration>
    @Binding var playhead: Duration
    @State var zoom: Double = 1
    @State var size: CGSize = .zero
    @State var scrollSize: CGSize = .zero
    @State var timelinePosition: Duration = .seconds(2)
    
    var body: some View {
        VStack(spacing: .zero) {
            // Toolbar
            toolBar
            
            SeparatorLine()
            
            // Timeline
            ScrollViewReader { scroller in
                ScrollView(.horizontal, showsIndicators: true) {
                    ZStack {
                        TimescaleView(timelineRange: $video.timelineRange, frameRate: video.frameRate)
                        
                        TimelineGestureView(bounds: $video.timelineRange, playhead: $playhead)
                            // отвечает за размер таймлайна
                            .frame(width: scrollSize.width)
                        
                        VideoLineView(
                            video: video,
                            currentBounds: $currentRange,
                            playhead: $playhead
                        )
                        .frame(minHeight: 24, idealHeight: 48, maxHeight: 96)
                    }
                    .overlay {
                        PlayheadViewNew(bounds: $video.timelineRange, playhead: $playhead, frameRate: video.frameRate)
                    }
                }
                .onChange(of: zoom) { newZoom in
                    scrollSize.width = size.width * newZoom
                    // scroller.scrollTo(1, anchor: .center)
                }
                .onChange(of: timelinePosition) { newTimelinePosition in
                    print(newTimelinePosition)
                }
            }
            .onAppear {
                switch video.range {
                case .full:
                    currentRange = .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration)))
                case .excerpt:
                    currentRange = video.rangeTimecode ?? .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration)))
                }
            }
            .frame(minHeight: AppGrid.pt72)
        }
        .readSize { size in
            self.size = size
            if scrollSize.width < size.width {
                scrollSize = size
            }
        }
    }
    
    var toolBar: some View {
        HStack(spacing: AppGrid.pt16) {
            TimecodeView(playhead: $playhead, frameRate: $video.frameRate)
            Spacer()
            MatchFrameView(video: video, playhead: $playhead)
            RangeButtons(playhead: $playhead, currentRange: $currentRange)
            Spacer()
            ZoomSlider(zoom: $zoom)
                .frame(width: AppGrid.pt160)
        }
        .frame(height: AppGrid.pt24)
        .padding(AppGrid.pt8)
    }
}

#Preview("TimelineView") {
    struct PreviewWrapper: View {
        @ObservedObject var video: Video = .placeholder
        @State var currentBounds: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(5)))
        @State var playhead: Duration = .seconds(1)
        
        var body: some View {
            VSplitView {
                Text("Top")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                TimelineView(video: video, currentRange: $currentBounds, playhead: $playhead)
            }
        }
    }
    
    return PreviewWrapper()
        .frame(width: 600)
}
