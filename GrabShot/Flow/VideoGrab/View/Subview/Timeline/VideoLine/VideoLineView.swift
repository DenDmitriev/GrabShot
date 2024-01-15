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
    @Binding var playhead: Duration
    
    @State var size: CGSize = .zero
    @State var stepWidthInPixel: CGFloat = .zero
    @State var showContextLeft: Bool = false
    @State var showContextRight: Bool = false
    
    var body: some View {
        ZStack {
            // Фон видео в полном размере по длине
            RoundedRectangle(cornerRadius: AppGrid.pt8)
                .fill(.separator)
                .readSize { size in
                    // Длина общего диапазона в секундах
                    let rangeSeconds = video.timelineRange.upperBound.seconds - video.timelineRange.lowerBound.seconds
                    // Шаг в пикселях на 1 секунду
                    self.stepWidthInPixel = size.width / rangeSeconds
                    // Общая длина
                    self.size = size
                }
                // Наложения
                // Важно располагать в `overlay` чтоб не потерять жесты
                .overlay {
                    if let colorBounds = video.lastRangeTimecode, !video.grabColors.isEmpty {
                        colorsView(colorBounds: colorBounds)
                    }
                }
                // Нажатие по всему таймлайну для пермещения курсора
                .onTapGesture(coordinateSpace: .local) { location in
                    let xCursorOffset = min(max(0, location.x), size.width)
                    let newValue = video.timelineRange.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                    playhead = .seconds(newValue)
                }
                // Перетаскивание курсора по линии таймлайна
                .highPriorityGesture(dragGestureOnVideo())
            
            // Рамка ручного диапазона
            rangeSliderView(size: size, video: video)
        }
        .onChange(of: video) { newView in
            updateVideo(video: newView)
        }
        .onChange(of: video.rangeTimecode.lowerBound) { newLowerBound in
            updateRange(video: video)
            playhead = newLowerBound
        }
        .onChange(of: video.rangeTimecode.upperBound) { newUpperBound in
            updateRange(video: video)
            playhead = newUpperBound
        }
    }
    
    private func updateVideo(video: Video) {
        let rangeSeconds = video.timelineRange.upperBound.seconds - video.timelineRange.lowerBound.seconds
        self.stepWidthInPixel = size.width / rangeSeconds
    }
    
    private func updateRange(video: Video) {
        if video.timelineRange == video.rangeTimecode {
            video.range = .full
        } else {
            video.range = .excerpt
        }
    }
    
    private func colorsView(colorBounds: ClosedRange<Duration>) -> some View {
        let sliderViewYCenter = size.height / 2
        let leftColorTimelineLocation = colorBounds.lowerBound.seconds * stepWidthInPixel
        let rightColorTimelineLocation = colorBounds.upperBound.seconds * stepWidthInPixel
        let xColorTimelinePosition: CGFloat = leftColorTimelineLocation + (rightColorTimelineLocation - leftColorTimelineLocation) / 2
        
        return colorLine(
            from: .init(x: leftColorTimelineLocation, y: sliderViewYCenter),
            to: .init(x: rightColorTimelineLocation, y: sliderViewYCenter)
        )
        .position(x: xColorTimelinePosition, y: sliderViewYCenter)
    }
    
    private func rangeSliderView(size: CGSize, video: Video) -> some View {
        ZStack {
            // Середина по оси Y
            let sliderViewYCenter = size.height / 2
            
            // Вычисление исходного положения левого ползунка
            let leftThumbLocation = rangeLocation(for: .left, video: video, stepWidthInPixel: stepWidthInPixel)
            
            // Вычисление исходного положения правого ползунка
            let rightThumbLocation = rangeLocation(for: .right, video: video, stepWidthInPixel: stepWidthInPixel)
            
            // Координата текущего диапазона по оси X
            let xLineBetweenThumbs: CGFloat = leftThumbLocation + (rightThumbLocation - leftThumbLocation) / 2
            
            // Рамка выбранного диапазона
            let from: CGPoint = .init(x: leftThumbLocation, y: sliderViewYCenter)
            let to: CGPoint = .init(x: rightThumbLocation, y: sliderViewYCenter)
            lineBetweenThumbs(from: from, to: to)
                .position(x: xLineBetweenThumbs, y: sliderViewYCenter)
            
            // Левая рамка выбранного диапазона
            let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
            thumbView(value: video.rangeTimecode.lowerBound, thumb: .left)
                .position(leftThumbPoint)
                .highPriorityGesture(dragGestureOnBounds(thumb: .left))
            
            // Правая рамка выбранного диапазона
            let rightThumbPoint = CGPoint(x: rightThumbLocation, y: sliderViewYCenter)
            thumbView(value: video.rangeTimecode.upperBound, thumb: .right)
                .position(rightThumbPoint)
                .highPriorityGesture(dragGestureOnBounds(thumb: .right))
        }
    }
    
    private func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
        RoundedRectangle(cornerRadius: AppGrid.pt8)
            .inset(by: AppGrid.pt2)
            .stroke(styleForThumbLine(isBounds: isBounds(video: video)), lineWidth: AppGrid.pt4)
            .frame(maxWidth: to.x - from.x, maxHeight: size.height)
    }
    
    private func colorLine(from: CGPoint, to: CGPoint) -> some View {
        HStack(spacing: .zero) {
            ForEach(video.grabColors.indices, id: \.self) { index in
                Rectangle()
                    .fill(video.grabColors[index])
            }
        }
        .frame(maxWidth: to.x - from.x, maxHeight: size.height)
        .cornerRadius(AppGrid.pt8)
    }
    
    enum Thumb {
        case left, right
    }
    
    /// Drag button for edit `rangeTimeline` in `Video`
    private func thumbView(value: Duration, thumb: Thumb) -> some View {
        let showContext: Binding<Bool>
        switch thumb {
        case .left:
            showContext = $showContextLeft
        case .right:
            showContext = $showContextRight
        }
        
        let widthButton = AppGrid.pt24
        
        return Image(systemName: thumb == .left ? "chevron.compact.left" : "chevron.compact.right")
            .frame(width: widthButton, height: size.height)
            .font(.title.weight(.bold))
            .foregroundStyle(styleForThumb(isBounds: isBounds(video: video)))
            .shadow(radius: isBounds(video: video) ? .zero : AppGrid.pt4)
            .popover(isPresented: showContext, content: {
                contextView(value: value)
            })
            .offset(x: {
                switch thumb {
                case .left:
                    return widthButton / 2
                case .right:
                    return -widthButton / 2
                }
            }())
    }
    
    /// Timecode context view.
    func contextView(value: Duration) -> some View {
        Text(value.formatted(.timecode(frameRate: video.frameRate)))
            .lineLimit(1)
            .font(.callout.weight(.light))
            .frame(width: AppGrid.pt72)
            .padding(AppGrid.pt8)
    }
    
    /// Show context control.
    func showContext(for thumb: Thumb, isShow: Bool) {
        withAnimation(.easeInOut(duration: 0.25)) {
            switch thumb {
            case .left:
                showContextLeft = isShow
            case .right:
                showContextRight = isShow
            }
        }
    }
    
    /// Get x coordinate for side of `rangeTimecode` in `Video`.
    func rangeLocation(for side: Thumb, video: Video, stepWidthInPixel: CGFloat) -> CGFloat {
        guard stepWidthInPixel > 0 else { return .zero }
        switch side {
        case .left:
            let location = video.rangeTimecode.lowerBound.seconds * stepWidthInPixel
            return location
        case .right:
            let location = video.rangeTimecode.upperBound.seconds * stepWidthInPixel
            return location
        }
    }
    
    /// Style for control drag buttons in line.
    private func styleForThumb(isBounds: Bool) -> some ShapeStyle {
        if isBounds {
            AnyShapeStyle(.secondary)
        } else {
            AnyShapeStyle(.background)
        }
    }
    
    /// Style for `rangeTimecode` in `Video`
    private func styleForThumbLine(isBounds: Bool) -> some ShapeStyle {
        if isBounds {
            AnyShapeStyle(.clear)
        } else {
            AnyShapeStyle(.yellow)
        }
    }
    
    /// Check current `rangeBounds` with video `timelineRange`.
    private func isBounds(video: Video) -> Bool {
        let bounds = video.timelineRange
        let leftBounds = video.rangeTimecode.lowerBound == bounds.lowerBound
        let rightBounds = video.rangeTimecode.upperBound == bounds.upperBound
        return leftBounds && rightBounds
    }
}

#Preview("VideoLineView") {
    struct PreviewWrapper: View {
        @State var playhead: Duration = .seconds(50)
        @ObservedObject var video: Video = .placeholder
        
        var body: some View {
            VStack {
                VideoLineView(video: video, playhead: $playhead)
                    .frame(width: 600, height: 100)
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
