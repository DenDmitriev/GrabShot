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
                .frame(height: AppGrid.pt36)
                .padding(AppGrid.pt8)
            
            Rectangle()
                .fill(.deep)
                .frame(height: 0.5)
            
            // Timeline
            ScrollViewReader { scroller in
                ScrollView(.horizontal, showsIndicators: true) {
                    VStack {
                        TimescaleView(timelineRange: $video.timelineRange, frameRate: video.frameRate)
                        
                        VideoLineView(
                            currentBounds: $currentRange,
                            colorBounds: $video.lastRangeTimecode,
                            frameRate: $video.frameRate,
                            playhead: $playhead,
                            colors: $video.grabColors,
                            bounds: video.timelineRange
                        )
                        .frame(width: scrollSize.width) // отвечает за размер таймлайна
                        .onChange(of: currentRange.lowerBound) { newLowerBound in
                            let newRange = newLowerBound...currentRange.upperBound
                            updateVideoRange(range: newRange)
                            playhead = newRange.lowerBound
                        }
                        .onChange(of: currentRange.upperBound) { newUpperBound in
                            let newRange = currentRange.lowerBound...newUpperBound
                            updateVideoRange(range: newRange)
                            playhead = newRange.upperBound
                        }
                    }
                    .overlay {
                        PlayheadView()
                    }
                }
                .onChange(of: zoom) { newZoom in
                    scrollSize.width = size.width * zoom
                    // scroller.scrollTo(1, anchor: .center)
                }
                .onChange(of: timelinePosition) { newTimelinePosition in
                    print(newTimelinePosition)
                }
                
            }
            .frame(minHeight: AppGrid.pt72)
            .onAppear {
                switch video.range {
                case .full:
                    currentRange = .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration)))
                case .excerpt:
                    currentRange = video.rangeTimecode ?? .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration)))
                }
            }
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
            ZoomSlider(zoom: $zoom)
                .frame(width: AppGrid.pt160)
        }
    }
    
    private func updateVideoRange(range: ClosedRange<Duration>) {
        video.rangeTimecode = range
        if video.timelineRange == range {
            video.range = .full
        } else {
            video.range = .excerpt
        }
    }
}

#Preview("TimelineView") {
    struct PreviewWrapper: View {
        @ObservedObject var video: Video = .placeholder
        @State var currentBounds: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(1), upper: .seconds(4)))
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
