//
//  PlayerControlsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.12.2023.
//
// https://stackoverflow.com/questions/62587261/swiftui-2-handle-range-slider

import SwiftUI

struct VideoLineView: View {
    @ObservedObject var video: Video
    @Binding var currentBounds: ClosedRange<Duration>
    @Binding var playhead: Duration
    
    @State private var size: CGSize = .zero
    @State private var showContextLeft: Bool = false
    @State private var showContextRight: Bool = false
    @State private var showContextCursor: Bool = false
    @State private var showCursor: Bool = true
    
    var body: some View {
        ZStack {
            Color.clear
                .readSize { size in
                    self.size = size
                }
            
            sliderView(size: size)
                .frame(height: size.height)
        }
        .onChange(of: currentBounds.lowerBound) { newLowerBound in
            let newRange = newLowerBound...currentBounds.upperBound
            updateVideoRange(range: newRange)
            playhead = newRange.lowerBound
        }
        .onChange(of: currentBounds.upperBound) { newUpperBound in
            let newRange = currentBounds.lowerBound...newUpperBound
            updateVideoRange(range: newRange)
            playhead = newRange.upperBound
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
    
    @ViewBuilder
    private func sliderView(size: CGSize) -> some View {
        let sliderViewYCenter = size.height / 2
        ZStack {
            let bounds = video.timelineRange
            // Длина общего диапазона
            let sliderBound = bounds.upperBound.seconds - bounds.lowerBound.seconds
            // Шаг в пикселях на 1 секунду
            let stepWidthInPixel = size.width / sliderBound
            
            // Вычисление исходного положения левого ползунка
            let leftThumbLocation: CGFloat =
            currentBounds.lowerBound == bounds.lowerBound
            ? 0
            : currentBounds.lowerBound.seconds * stepWidthInPixel
            
            // Вычисление исходного положения правого ползунка
            let rightThumbLocation: CGFloat =
            currentBounds.upperBound == bounds.upperBound
            ? bounds.upperBound.seconds * stepWidthInPixel
            : currentBounds.upperBound.seconds * stepWidthInPixel
            
            // Вычисление исходного положения курсора
            // let cursorLocation = CGFloat(playhead.seconds) * stepWidthInPixel
            
            // Координата текущего диапазона по оси X
            let xLineBetweenThumbs: CGFloat = leftThumbLocation + (rightThumbLocation - leftThumbLocation) / 2
            
            // Линия времени
            ZStack {
                // Полный диапазон
                RoundedRectangle(cornerRadius: AppGrid.pt8)
                    .fill(.separator)
                    .frame(height: size.height)
                
                // Цветовой диапазон
                if !video.grabColors.isEmpty, let colorBounds = video.lastRangeTimecode {
                    let leftColorTimelineLocation: CGFloat = colorBounds.lowerBound.seconds * stepWidthInPixel
                    let rightColorTimelineLocation: CGFloat = colorBounds.upperBound.seconds * stepWidthInPixel
                    let xColorTimelinePosition: CGFloat = leftColorTimelineLocation + (rightColorTimelineLocation - leftColorTimelineLocation) / 2
                    colorTimeline(
                        from: .init(x: leftColorTimelineLocation, y: sliderViewYCenter),
                        to: .init(x: rightColorTimelineLocation, y: sliderViewYCenter)
                    )
                    .position(x: xColorTimelinePosition, y: sliderViewYCenter)
                }
                
                // Выбранный диапазон
                lineBetweenThumbs(
                    from: .init(x: leftThumbLocation, y: sliderViewYCenter),
                    to: .init(x: rightThumbLocation, y: sliderViewYCenter)
                )
                .position(
                    x: xLineBetweenThumbs,
                    y: sliderViewYCenter
                )
                
            }
            
            // Нажатие по всему таймлайну для пермещения курсора
            .onTapGesture(coordinateSpace: .local) { location in
                let xCursorOffset = min(max(0, location.x), size.width)
                let newValue = video.timelineRange.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                playhead = .seconds(newValue)
            }
            // Перетаскивание курсора по линии таймлана
            .gesture(
                DragGesture()
                    .onChanged { dragValue in
                        let dragLocation = dragValue.location
                        let xCursorOffset = min(max(0, dragLocation.x), size.width)
                        let newValue = video.timelineRange.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                        playhead = .seconds(newValue)
                    }
                    .onEnded { dragValue in
                    }
            )
            
            // Левая рамка выбранного диапазона
            let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
            
            thumbView(position: leftThumbPoint, value: currentBounds.lowerBound, thumb: .left, alignment: .leading)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { dragValue in
                            showCursor = false
                            showContext(for: .left, isShow: true)
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(max(0, dragLocation.x), size.width)
                            
                            let newValue = bounds.lowerBound.seconds + xThumbOffset / stepWidthInPixel
                            
                            // Stop the range thumbs from colliding each other
                            if newValue < currentBounds.upperBound.seconds {
                                currentBounds = Duration.seconds(newValue)...currentBounds.upperBound
                            }
                            
                        }
                        .onEnded { dragValue in
                            playhead = currentBounds.lowerBound
                            showCursor = true
                            showContext(for: .left, isShow: false)
                        }
                )
            
            // Правая рамка выбранного диапазона
            thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: currentBounds.upperBound, thumb: .right, alignment: .trailing)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { dragValue in
                            showCursor = false
                            showContext(for: .right, isShow: true)
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(max(leftThumbLocation, dragLocation.x), size.width)
                            
                            var newValue = xThumbOffset / stepWidthInPixel // convert back the value bound
                            newValue = min(newValue, bounds.upperBound.seconds)
                            
                            // Stop the range thumbs from colliding each other
                            if newValue > currentBounds.lowerBound.seconds {
                                currentBounds = currentBounds.lowerBound...Duration.seconds(newValue)
                            }
                        }
                        .onEnded { dragValue in
                            playhead = currentBounds.upperBound
                            showCursor = true
                            showContext(for: .right, isShow: false)
                        }
                )
        }
    }
    
    func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
        RoundedRectangle(cornerRadius: AppGrid.pt8)
            .inset(by: AppGrid.pt2)
            .stroke(styleForThumbLine(isBounds: isBounds()), lineWidth: AppGrid.pt4)
        //            .fill(isBounds() ? .clear : .yellow)
        //            .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
            .frame(maxWidth: to.x - from.x, maxHeight: size.height)
    }
    
    func colorTimeline(from: CGPoint, to: CGPoint) -> some View {
        HStack(spacing: .zero) {
            ForEach(Array(zip(video.grabColors.indices ,video.grabColors)), id: \.0) { index, color in
                Rectangle()
                    .fill(color)
            }
        }
        .frame(maxWidth: to.x - from.x, maxHeight: size.height)
        .cornerRadius(AppGrid.pt8)
    }
    
    private func styleForThumbLine(isBounds: Bool) -> some ShapeStyle {
        if isBounds {
            AnyShapeStyle(.clear)
        } else {
            AnyShapeStyle(.yellow)
        }
    }
    
    enum Thumb {
        case left, right, cursor
    }
    
    func cursorView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppGrid.pt2)
                .fill(.white)
                .frame(width: AppGrid.pt4, height: AppGrid.pt36)
                .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                .contentShape(Rectangle())
                .popover(isPresented: $showContextCursor, content: {
                    contextView(value: playhead)
                })
        }
    }
    
    func thumbView(position: CGPoint, value: Duration, thumb: Thumb, alignment: Alignment) -> some View {
        let showContext = { switch thumb {
        case .left:
            return $showContextLeft
        case .right:
            return $showContextRight
        default:
            return .constant(false)
        }}()
        let widthButton = AppGrid.pt24
        
        return Image(systemName: thumb == .left ? "chevron.compact.left" : "chevron.compact.right")
            .frame(width: widthButton, height: size.height)
            .background(content: {
                RoundedRectangle(cornerRadius: AppGrid.pt8)
                    .fill(styleForThumbLine(isBounds: isBounds()))
                    .frame(width: widthButton, height: size.height)
            })
            .font(.title.weight(.bold))
            .foregroundStyle(styleForThumb(isBounds: isBounds()))
            .popover(isPresented: showContext, content: {
                contextView(value: value)
            })
            .offset(x: {
                switch thumb {
                case .left:
                    return widthButton / 2
                case .right:
                    return -widthButton / 2
                default:
                    return .zero
                }
            }())
            .position(
                x: position.x,
                y: position.y
            )
    }
    
    private func styleForThumb(isBounds: Bool) -> some ShapeStyle {
        if isBounds {
            AnyShapeStyle(.secondary)
        } else {
            AnyShapeStyle(.background)
        }
    }
    
    func contextView(value: Duration) -> some View {
        Text(value.formatted(.timecode(frameRate: video.frameRate)))
            .lineLimit(1)
            .font(.callout.weight(.light))
            .frame(width: AppGrid.pt72)
            .padding(AppGrid.pt8)
    }
    
    private func isBounds() -> Bool {
        let bounds = video.timelineRange
        return currentBounds.lowerBound == bounds.lowerBound && currentBounds.upperBound == bounds.upperBound
    }
    
    private func showContext(for thumb: Thumb, isShow: Bool) {
        withAnimation(.easeInOut(duration: 0.25)) {
            switch thumb {
            case .left:
                showContextLeft = isShow
            case .right:
                showContextRight = isShow
            case .cursor:
                showContextCursor = isShow
            }
        }
    }
}

#Preview("VideoLineView") {
    struct PreviewWrapper: View {
        @State var currentBounds: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(1), upper: .seconds(4)))
        @State var cursor: Duration = .seconds(50)
        @State var frameRate: Double = 25
        @ObservedObject var video: Video = .placeholder
        
        var body: some View {
            VStack {
                VideoLineView(
                    video: video,
                    currentBounds: $currentBounds,
                    playhead: $cursor
                )
                
                VideoLineView(
                    video: video,
                    currentBounds: $video.timelineRange,
                    playhead: .constant(.seconds(50))
                )
            }
            .onAppear {
                video.lastRangeTimecode = currentBounds
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
