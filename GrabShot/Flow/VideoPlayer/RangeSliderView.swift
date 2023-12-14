//
//  PlayerControlsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.12.2023.
//
// https://stackoverflow.com/questions/62587261/swiftui-2-handle-range-slider

import SwiftUI

struct RangeSliderView: View {
    
    @Binding var currentBounds: ClosedRange<Double>
    @Binding var cursor: Double
    let sliderBounds: ClosedRange<Double>
    
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
            let sliderBoundDifference = sliderBounds.upperBound - sliderBounds.lowerBound
            let stepWidthInPixel = frame.width / sliderBoundDifference
            
            // Calculate Left Thumb initial position
            let leftThumbLocation: CGFloat = currentBounds.lowerBound == sliderBounds.lowerBound
            ? 0
            : (currentBounds.lowerBound - sliderBounds.lowerBound) * stepWidthInPixel
            
            // Calculate right thumb initial position
            let rightThumbLocation = currentBounds.upperBound * stepWidthInPixel
            
            let cursorLocation = CGFloat(cursor) * stepWidthInPixel
            
            let offsetXLineBetweenThumbs = (stepWidthInPixel * sliderBoundDifference - (rightThumbLocation - leftThumbLocation))/2 - leftThumbLocation
            
            // Timeline
            ZStack {
                // Timeline total
                RoundedRectangle(cornerRadius: Grid.pt8)
                    .fill(.white.opacity(0.25))
                    .frame(height: Grid.pt48)
                
                // Timeline between current bounds
                lineBetweenThumbs(from: .init(x: leftThumbLocation, y: sliderViewYCenter), to: .init(x: rightThumbLocation, y: sliderViewYCenter))
                    .offset(x: -offsetXLineBetweenThumbs)
                
            }
            .onTapGesture(coordinateSpace: .local) { location in
                let xCursorOffset = min(max(0, location.x), frame.width)
                let newValue = sliderBounds.lowerBound + xCursorOffset / stepWidthInPixel
                cursor = newValue
            }
            .highPriorityGesture(
                DragGesture()
                    .onChanged { dragValue in
                        showContext(for: .cursor, isShow: true)
                        let dragLocation = dragValue.location
                        let xCursorOffset = min(max(0, dragLocation.x), frame.width)
                        let newValue = sliderBounds.lowerBound + xCursorOffset / stepWidthInPixel
                        cursor = newValue
                    }
                    .onEnded { dragValue in
                        showContext(for: .cursor, isShow: false)
                    }
            )
            
            
            
            // Left Thumb Handle
            let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
            
            thumbView(position: leftThumbPoint, value: currentBounds.lowerBound, thumb: .left, alignment: .leading)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { dragValue in
                            showCursor = false
                            showContext(for: .left, isShow: true)
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(max(0, dragLocation.x), frame.width)
                            
                            let newValue = sliderBounds.lowerBound + xThumbOffset / stepWidthInPixel
                            
                            // Stop the range thumbs from colliding each other
                            if newValue < currentBounds.upperBound {
                                currentBounds = newValue...currentBounds.upperBound
                            }
                            
                        }
                        .onEnded { dragValue in
                            cursor = currentBounds.lowerBound
                            showCursor = true
                            showContext(for: .left, isShow: false)
                        }
                )
            
            // Right Thumb Handle
            thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: currentBounds.upperBound, thumb: .right, alignment: .trailing)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { dragValue in
                            showCursor = false
                            showContext(for: .right, isShow: true)
                            let dragLocation = dragValue.location
                            let xThumbOffset = min(max(leftThumbLocation, dragLocation.x), frame.width)
                            
                            var newValue = xThumbOffset / stepWidthInPixel // convert back the value bound
                            newValue = min(newValue, sliderBounds.upperBound)
                            
                            // Stop the range thumbs from colliding each other
                            if newValue > currentBounds.lowerBound {
                                currentBounds = currentBounds.lowerBound...newValue
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
                            newValue = min(newValue, sliderBounds.upperBound)
                            newValue = max(newValue, sliderBounds.lowerBound)
                            
                            // Stop the range thumbs from colliding each other
                            if sliderBounds ~= newValue {
                                cursor = newValue
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
        RoundedRectangle(cornerRadius: Grid.pt8)
            .fill(isBounds() ? .clear : .yellow)
            .frame(width: to.x - from.x, height: Grid.pt48)
    }
    
    enum Thumb {
        case left, right, cursor
    }
    
    func cursorView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Grid.pt2)
                .fill(.white)
                .frame(width: Grid.pt4, height: Grid.pt36)
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 2)
                .contentShape(Rectangle())
            
            contextView(value: cursor)
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
                .frame(width: Grid.pt24, height: Grid.pt48)
                .background(content: {
                    RoundedRectangle(cornerRadius: Grid.pt8)
                        .fill(isBounds() ? .clear : .yellow)
                        .frame(width: Grid.pt24, height: Grid.pt48)
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
        Text(Duration.build(seconds: value).formatted(.time(pattern: .hourMinuteSecond)))
            .font(.callout.weight(.light))
            .foregroundStyle(.white.opacity(0.7))
            .background(content: {
                RoundedRectangle(cornerRadius: Grid.pt4)
                    .fill(.black.opacity(0.8))
                    .padding(-Grid.pt4)
            })
            .offset(y: -Grid.pt48)
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
    RangeSliderView(currentBounds: .constant(25...75), cursor: .constant(50), sliderBounds: 0...100)
    //        .frame(width: 300, height: 125)
}
