//
//  TimelineScrollIndicator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct TimelineScrollIndicator: View {
    
    @Binding var zoom: Double
    @Binding var playhead: Duration
    @Binding var timelineRange: ClosedRange<Duration>
    @Binding var timelinePosition: Duration
    
    @State private var size: CGSize = .zero
    private let height: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Фон
            RoundedRectangle(cornerRadius: height / 2)
                .fill(.backgroundTwo)
            
            // Ползунок
            let middleY: CGFloat = size.height / 2
            let width: CGFloat = size.width / zoom
            let deltaRangeSeconds = (timelineRange.upperBound - timelineRange.lowerBound).seconds
            let stepX: CGFloat = size.width / (deltaRangeSeconds == .zero ? 1 : deltaRangeSeconds)
            let positionX: CGFloat = min(width / 2 + timelinePosition.seconds * stepX, size.width - width / 2)
            RoundedRectangle(cornerRadius: height / 2)
                .fill(.control)
                .frame(width: max(width - 2, 0), height: max(height - 2, 0))
                .shadow(radius: 1)
                .overlay {
                    RoundedRectangle(cornerRadius: height / 2)
                        .stroke(.bevelTwo, lineWidth: 0.5)
                }
                .position(x: 0 + positionX, y: middleY)
                .gesture(DragGesture()
                    .onChanged { dragLocation in
                        let locationX = min(
                            max(
                                0,
                                dragLocation.location.x
                            ),
                            size.width
                        ).round(to: 2)
                        let deltaRange = (timelineRange.upperBound - timelineRange.lowerBound).seconds
                        let seconds = min(
                            max(
                                locationX / width  * deltaRange,
                                timelineRange.lowerBound.seconds
                            ),
                            timelineRange.upperBound.seconds
                        )
                        timelinePosition = .seconds(seconds.round(to: 2))
                    }
                )
                .animation(.easeInOut, value: timelinePosition)
        }
        .readSize(onChange: { size in
            self.size = size
        })
        .frame(height: height)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var zoom: Double = 2
        @State var playhead: Duration = .seconds(3)
        @State var timelineRange: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(10)))
        @State var timelinePosition: Duration = .seconds(2)
        
        var body: some View {
            VStack {
                ZoomSlider(zoom: $zoom)
                
                ZStack {
                    Rectangle()
                        .fill(.background)
                        .frame(height: 30)
                    
                    TimelineScrollIndicator(zoom: $zoom, playhead: $playhead, timelineRange: $timelineRange, timelinePosition: $timelinePosition)
                        .padding()
                }
            }
        }
    }
    
    return VStack(spacing: .zero) {
        PreviewWrapper()
            .environment(\.colorScheme, .light)
        
        PreviewWrapper()
            .environment(\.colorScheme, .dark)
    }
    .padding()
}
