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
    @Binding var cursor: Duration
    let sliderBounds: ClosedRange<Duration>
    
    @State private var frame: CGRect = .zero
    @State private var showContextLeft: Bool = false
    @State private var showContextRight: Bool = false
    @State private var showContextCursor: Bool = false
    @State private var showCursor: Bool = true
    
    var body: some View {
        sliderView(frame: frame)
            .overlay(
                GeometryReader { geometryProxy in
                    Color.clear
                        .onAppear {
                            self.frame = geometryProxy.frame(in: .local)
                        }
                }
            )
            .background(.black)
    }
    
    @ViewBuilder
    private func sliderView(frame: CGRect) -> some View {
        let sliderViewYCenter = frame.size.height / 2
        ZStack {
            let sliderBoundDifference = sliderBounds.upperBound.seconds - sliderBounds.lowerBound.seconds
            let stepWidthInPixel = frame.width / sliderBoundDifference
            
            // Calculate Left Thumb initial position
            let leftThumbLocation: CGFloat = currentBounds.lowerBound == sliderBounds.lowerBound
            ? 0
            : (currentBounds.lowerBound - sliderBounds.lowerBound).seconds * stepWidthInPixel
            
            // Calculate right thumb initial position
            let rightThumbLocation = currentBounds.upperBound.seconds * stepWidthInPixel
            
            let cursorLocation = CGFloat(cursor.seconds) * stepWidthInPixel
            
            let offsetXLineBetweenThumbs = (stepWidthInPixel * sliderBoundDifference - (rightThumbLocation - leftThumbLocation))/2 - leftThumbLocation
            
            // Timeline
            ZStack {
                // Timeline total
                RoundedRectangle(cornerRadius: AppGrid.pt8)
                    .fill(.white.opacity(0.25))
                    .frame(height: AppGrid.pt48)
                
                // Timeline between current bounds
                lineBetweenThumbs(from: .init(x: leftThumbLocation, y: sliderViewYCenter), to: .init(x: rightThumbLocation, y: sliderViewYCenter))
                    .offset(x: -offsetXLineBetweenThumbs)
                
            }
            .onTapGesture(coordinateSpace: .local) { location in
                let xCursorOffset = min(max(0, location.x), frame.width)
                let newValue = sliderBounds.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                cursor = .seconds(newValue)
            }
            .highPriorityGesture(
                DragGesture()
                    .onChanged { dragValue in
                        showContext(for: .cursor, isShow: true)
                        let dragLocation = dragValue.location
                        let xCursorOffset = min(max(0, dragLocation.x), frame.width)
                        let newValue = sliderBounds.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                        cursor = .seconds(newValue)
                    }
                    .onEnded { dragValue in
                        showContext(for: .cursor, isShow: false)
                    }
            )
            
            
            
            // Left Thumb Handle
            let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
            
            thumbView(position: leftThumbPoint, value: currentBounds.lowerBound.seconds, thumb: .left, alignment: .leading)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { dragValue in
                            showCursor = false
                            showContext(for: .left, isShow: true)
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(max(0, dragLocation.x), frame.width)
                            
                            let newValue = sliderBounds.lowerBound.seconds + xThumbOffset / stepWidthInPixel
                            
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
            
            // Right Thumb Handle
            thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: currentBounds.upperBound.seconds, thumb: .right, alignment: .trailing)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { dragValue in
                            showCursor = false
                            showContext(for: .right, isShow: true)
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(max(leftThumbLocation, dragLocation.x), frame.width)
                            
                            var newValue = xThumbOffset / stepWidthInPixel // convert back the value bound
                            newValue = min(newValue, sliderBounds.upperBound.seconds)
                            
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
            
            // Cursor view
            cursorView()
                .position(x: cursorLocation, y: sliderViewYCenter)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged{ dragValue in
                            showContext(for: .cursor, isShow: true)
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(dragLocation.x, frame.width)
                            
                            var newValue = xThumbOffset / stepWidthInPixel // convert back the value bound
                            newValue = min(newValue, sliderBounds.upperBound.seconds)
                            newValue = max(newValue, sliderBounds.lowerBound.seconds)
                            
                            // Stop the range thumbs from colliding each other
                            let newCursor = Duration.seconds(newValue)
                            if sliderBounds ~= newCursor {
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
            .fill(isBounds() ? .clear : .yellow)
            .frame(width: to.x - from.x, height: AppGrid.pt48)
    }
    
    enum Thumb {
        case left, right, cursor
    }
    
    func cursorView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppGrid.pt2)
                .fill(.white)
                .frame(width: AppGrid.pt4, height: AppGrid.pt36)
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 2)
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
                        .fill(isBounds() ? .clear : .yellow)
                        .frame(width: AppGrid.pt24, height: AppGrid.pt48)
                })
                .font(.title.weight(.bold))
                .foregroundColor(isBounds() ? .gray : .black)
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
        return currentBounds.lowerBound == sliderBounds.lowerBound && currentBounds.upperBound == sliderBounds.upperBound
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
    RangeSliderView(
        currentBounds: .constant(.init(uncheckedBounds: (lower: .seconds(25), upper: .seconds(75)))),
        cursor: .constant(.seconds(50)),
        sliderBounds: .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(100)))
    )
    //        .frame(width: 300, height: 125)
}
