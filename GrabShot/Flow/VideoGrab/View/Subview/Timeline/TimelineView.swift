//
//  TimelineView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.01.2024.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var video: Video
    @Binding var playhead: Duration
    var onTabAction: ((Duration) -> Void)
    @State var zoom: Double = 1
    @State var size: CGSize = .zero
    @State var scrollSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: .zero) {
            // Toolbar
            toolBar
            
            SeparatorLine()
            
            // Timeline
            ScrollViewReader { scroller in
                ScrollView(.horizontal, showsIndicators: true) {
                    ZStack(alignment: .bottom) {
                        TimerulerNewView(frameRate: $video.frameRate, range: $video.timelineRange)
                            .frame(width: scrollSize.width)
                            .frame(maxHeight: .infinity, alignment: .top)
                        
                        TimelineGestureView(bounds: $video.timelineRange, playhead: $playhead) { newPlayhead in
                            onTabAction(newPlayhead)
                            playhead = newPlayhead
                        }
                            .frame(width: scrollSize.width)
//                        
                        VideoLineView(video: video, playhead: $playhead) { newPlayhead in
                            onTabAction(newPlayhead)
                            playhead = newPlayhead
                        }
                        .frame(maxHeight: AppGrid.pt80)
                        
//                                        RoundedRectangle(cornerRadius: 32)
//                                            .fill(.pink)
                    }
                    .overlay {
                        PlayheadView(bounds: $video.timelineRange, playhead: $playhead, frameRate: $video.frameRate)
                            .padding(.bottom, AppGrid.pt2)
                    }
                }
                .onChange(of: zoom) { newZoom in
                    scrollSize.width = size.width * newZoom
                    scroller.scrollTo(PlayheadView.scrollId, anchor: .center)
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
                .foregroundStyle(.secondary)
            Spacer()
            RangeButtons(playhead: $playhead, currentRange: $video.rangeTimecode)
            Spacer()
            ZoomSlider(zoom: $zoom)
                .frame(width: AppGrid.pt160)
        }
        .frame(height: AppGrid.pt24)
        .padding(AppGrid.pt8)
        .background(.bar)
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
                
                TimelineView(video: video, playhead: $playhead) { newGesturePlayhead in
                    print("taped to", newGesturePlayhead.formatted(.timecode(frameRate: video.frameRate)))
                }
            }
        }
    }
    
    return PreviewWrapper()
        .frame(width: 600)
}
