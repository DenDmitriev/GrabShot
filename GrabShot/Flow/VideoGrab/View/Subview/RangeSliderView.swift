//
//  PlayerControlsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.12.2023.
//
// https://stackoverflow.com/questions/62587261/swiftui-2-handle-range-slider

import SwiftUI

struct RangeSliderView: View {
    
    @Binding var currentBounds: ClosedRange<Duration>
    @Binding var colorBounds: ClosedRange<Duration>?
    @Binding var cursor: Duration
    @Binding var colors: [Color]
    let bounds: ClosedRange<Duration>
    
    @State private var size: CGSize = .zero
    @State private var showContextLeft: Bool = false
    @State private var showContextRight: Bool = false
    @State private var showContextCursor: Bool = false
    @State private var showCursor: Bool = true
    
    var body: some View {
        sliderView(size: size)
            .readSize(onChange: { size in
                self.size = size
            })
    }
    
    @ViewBuilder
    private func sliderView(size: CGSize) -> some View {
        let sliderViewYCenter = size.height / 2
        ZStack {
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
            let cursorLocation = CGFloat(cursor.seconds) * stepWidthInPixel
            
            // Координата текущего диапазона по оси X
            let xLineBetweenThumbs: CGFloat = leftThumbLocation + (rightThumbLocation - leftThumbLocation) / 2
            
            // Линия времени
            ZStack {
                // Полный диапазон
                    RoundedRectangle(cornerRadius: AppGrid.pt8)
                        .fill(.separator)
                        .frame(height: AppGrid.pt48)
                
                // Цветовой диапазон
                if !colors.isEmpty, let colorBounds {
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
                let newValue = bounds.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                cursor = .seconds(newValue)
            }
            // Перетаскивание курсора по линии таймлана
            .highPriorityGesture(
                DragGesture()
                    .onChanged { dragValue in
                        showContext(for: .cursor, isShow: true)
                        let dragLocation = dragValue.location
                        let xCursorOffset = min(max(0, dragLocation.x), size.width)
                        let newValue = bounds.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                        cursor = .seconds(newValue)
                    }
                    .onEnded { dragValue in
                        showContext(for: .cursor, isShow: false)
                    }
            )
            
            // Левая рамка выбранного диапазона
            let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
            
            thumbView(position: leftThumbPoint, value: currentBounds.lowerBound.seconds, thumb: .left, alignment: .leading)
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
                            cursor = currentBounds.lowerBound
                            showCursor = true
                            showContext(for: .left, isShow: false)
                        }
                )
            
            // Правая рамка выбранного диапазона
            thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: currentBounds.upperBound.seconds, thumb: .right, alignment: .trailing)
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
                            cursor = currentBounds.upperBound
                            showCursor = true
                            showContext(for: .right, isShow: false)
                        }
                )
            
            // Курсор
            cursorView()
                .position(x: cursorLocation, y: sliderViewYCenter)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged{ dragValue in
                            showContext(for: .cursor, isShow: true)
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(dragLocation.x, size.width)
                            
                            var newValue = xThumbOffset / stepWidthInPixel // convert back the value bound
                            newValue = min(newValue, bounds.upperBound.seconds)
                            newValue = max(newValue, bounds.lowerBound.seconds)
                            
                            // Stop the range thumbs from colliding each other
                            let newCursor = Duration.seconds(newValue)
                            if bounds ~= newCursor {
                                cursor = newCursor
                            }
                        }
                        .onEnded { dragValue in
                            showContext(for: .cursor, isShow: false)
                        }
                )
                .hidden(!showCursor)
        }
    }
    
    func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
        RoundedRectangle(cornerRadius: AppGrid.pt8)
            .inset(by: AppGrid.pt2)
            .stroke(styleForThumbLine(isBounds: isBounds()), lineWidth: AppGrid.pt4)
//            .fill(isBounds() ? .clear : .yellow)
//            .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
            .frame(maxWidth: to.x - from.x, maxHeight: AppGrid.pt48)
    }
    
    func colorTimeline(from: CGPoint, to: CGPoint) -> some View {
        HStack(spacing: .zero) {
            ForEach(Array(zip(colors.indices ,colors)), id: \.0) { index, color in
                Rectangle()
                    .fill(color)
            }
        }
        .frame(maxWidth: to.x - from.x, maxHeight: AppGrid.pt48)
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
            
            contextView(value: cursor.timeInterval)
                .hidden(!showContextCursor)
        }
    }
    
    func thumbView(position: CGPoint, value: CGFloat, thumb: Thumb, alignment: Alignment) -> some View {
        ZStack(alignment: alignment) {
            contextView(value: value)
                .hidden({ switch thumb {
                case .left:
                    return !showContextLeft
                case .right:
                    return !showContextRight
                default:
                    return true
                }}())
            
            Image(systemName: thumb == .left ? "chevron.compact.left" : "chevron.compact.right")
                .frame(width: AppGrid.pt24, height: AppGrid.pt48)
                .background(content: {
                    RoundedRectangle(cornerRadius: AppGrid.pt8)
                        .fill(styleForThumbLine(isBounds: isBounds()))
                        .frame(width: AppGrid.pt24, height: AppGrid.pt48)
                })
                .font(.title.weight(.bold))
                .foregroundStyle(styleForThumb(isBounds: isBounds()))
        }
        .offset(x: {
            switch thumb {
            case .left:
                return 20
            case .right:
                return -20
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
    
    func contextView(value: TimeInterval) -> some View {
        Text(Duration.seconds(value).formatted(.time(pattern: .hourMinuteSecond)))
            .font(.callout.weight(.light))
            .foregroundStyle(.white.opacity(0.7))
            .background(content: {
                RoundedRectangle(cornerRadius: AppGrid.pt4)
                    .fill(.black.opacity(0.8))
                    .padding(-AppGrid.pt4)
            })
            .offset(y: -AppGrid.pt48)
    }
    
    private func isBounds() -> Bool {
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

#Preview("PlayerControlsView") {
    struct PreviewWrapper: View {
        @State var currentBounds: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(25), upper: .seconds(75)))
        @State var cursor: Duration = .seconds(50)
        @State var colors: [Color] = Video.placeholder.colors
        
        var body: some View {
            VStack {
                RangeSliderView(
                    currentBounds: $currentBounds, 
                    colorBounds: .constant(.init(uncheckedBounds: (lower: .seconds(15), upper: .seconds(40)))),
                    cursor: $cursor,
                    colors: $colors,
                    bounds: .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(100)))
                )
                
                RangeSliderView(
                    currentBounds: .constant(.init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(100)))),
                    colorBounds: .constant(.init(uncheckedBounds: (lower: .seconds(15), upper: .seconds(40)))),
                    cursor: .constant(.seconds(50)),
                    colors: $colors,
                    bounds: .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(100)))
                )
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
