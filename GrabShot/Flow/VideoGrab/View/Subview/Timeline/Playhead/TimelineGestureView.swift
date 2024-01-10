//
//  PlayheadView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct TimelineGestureView: View {
    @Binding var bounds: ClosedRange<Duration>
    @Binding var playhead: Duration
    @State private var size: CGSize = .zero
    // Шаг в пикселях на 1 секунду
    @State private var stepWidthInPixel: CGFloat = .zero
    
    var body: some View {
        Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .readSize { size in
                self.size = size
                stepWidthInPixel = calcStep(bounds: bounds)
            }
            .onChange(of: bounds) { newBounds in
                stepWidthInPixel = calcStep(bounds: newBounds)
            }
            // Нажатие по всему таймлайну для пермещения курсора
            .onTapGesture(coordinateSpace: .local) { location in
                let xCursorOffset = min(max(0, location.x), size.width)
                let newValue = bounds.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                playhead = .seconds(newValue)
            }
            // Перетаскивание курсора по линии таймлана
            .gesture(
                DragGesture()
                    .onChanged { dragValue in
                        let dragLocation = dragValue.location
                        let xCursorOffset = min(max(0, dragLocation.x), size.width)
                        let newValue = bounds.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                        playhead = .seconds(newValue)
                    }
                    .onEnded { dragValue in
                    }
            )
    }
    
    private func calcStep(bounds: ClosedRange<Duration>) -> CGFloat {
        let sliderBound = bounds.upperBound.seconds - bounds.lowerBound.seconds
        let stepWidthInPixel = size.width / sliderBound
        return stepWidthInPixel
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var bounds: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(100)))
        @State var playhead: Duration = .seconds(50)
        @State var frameRate: Double = 25
        @State private var size: CGSize = .init(width: 500, height: 100)
        
        var body: some View {
            TimelineGestureView(bounds: $bounds, playhead: $playhead)
                .background {
                    let sliderBound = bounds.upperBound.seconds - bounds.lowerBound.seconds
                    // Шаг в пикселях на 1 секунду
                    let stepWidthInPixel = size.width / sliderBound
                    let playheadLocationX = CGFloat(playhead.seconds) * stepWidthInPixel
                    let playheadLocationY = size.height / 2
                    
                    Circle()
                        .fill(.pink)
                        .position(x: playheadLocationX, y: playheadLocationY)
                }
                .frame(width: size.width, height: size.height)
        }
    }
    
    return PreviewWrapper()
        .padding()
}
