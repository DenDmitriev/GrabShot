//
//  Gesture+VideoLineView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 11.01.2024.
//

import SwiftUI

extension VideoLineView {
    func dragGestureOnVideo() -> some Gesture {
        DragGesture()
            .onChanged { dragValue in
                let dragLocation = dragValue.location
                let xCursorOffset = min(max(0, dragLocation.x), size.width)
                let newValue = video.timelineRange.lowerBound.seconds + xCursorOffset / stepWidthInPixel
                playhead = .seconds(newValue)
            }
            .onEnded { dragValue in }
    }
    
    func dragGestureOnBounds(thumb: Thumb) -> some Gesture {
        DragGesture()
            .onChanged { dragValue in
                showContext(for: thumb, isShow: true)
                let dragLocation = dragValue.location
                let xThumbOffset: CGFloat
                switch thumb {
                case .left:
                    // Вычисление положения правого ползунка
                    let rightThumbLocation = rangeLocation(for: .right, video: video, stepWidthInPixel: stepWidthInPixel)
                    
                    xThumbOffset = min(max(0, dragLocation.x), rightThumbLocation)
                case .right:
                    // Вычисление положения левого ползунка
                    let leftThumbLocation = rangeLocation(for: .left, video: video, stepWidthInPixel: stepWidthInPixel)
                    
                    xThumbOffset = min(max(leftThumbLocation, dragLocation.x), size.width)
                }
                let newValue: Double
                switch thumb {
                case .left:
                    let proxy = video.timelineRange.lowerBound.seconds + xThumbOffset / stepWidthInPixel
                    newValue = max(proxy, video.timelineRange.lowerBound.seconds)
                case .right:
                    let proxy = xThumbOffset / stepWidthInPixel
                    newValue = min(proxy, video.timelineRange.upperBound.seconds)
                }
                
                // Stop the range thumbs from colliding each other
                switch thumb {
                case .left:
                    if newValue < video.rangeTimecode.upperBound.seconds {
                        video.rangeTimecode = Duration.seconds(newValue)...video.rangeTimecode.upperBound
                    }
                case .right:
                    if newValue > video.rangeTimecode.lowerBound.seconds {
                        video.rangeTimecode = video.rangeTimecode.lowerBound...Duration.seconds(newValue)
                    }
                }
            }
            .onEnded { dragValue in
                switch thumb {
                case .left:
                    playhead = video.rangeTimecode.lowerBound
                case .right:
                    playhead = video.rangeTimecode.upperBound
                }
                showContext(for: thumb, isShow: false)
            }
    }
}
