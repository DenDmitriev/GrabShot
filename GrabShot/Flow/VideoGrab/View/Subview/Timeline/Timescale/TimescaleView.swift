//
//  TimescaleView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct TimescaleView: View {
    
    @Binding var timelineRange: ClosedRange<Duration>
    let frameRate: Double
    
    private let ticks: [TimeTick]
    @State private var countUnits: Int = .zero
    @State private var range: [Duration] = []
    private let minWidthUnit: CGFloat = AppGrid.pt140
    
    init(timelineRange: Binding<ClosedRange<Duration>>, frameRate: Double) {
        self._timelineRange = timelineRange
        self.frameRate = frameRate
        if frameRate > 2 {
            var ticks: [TimeTick] = []
            ticks.append(.major)
            for index in 2..<Int(frameRate.rounded(.up)) {
                let tick: TimeTick = index % 2 == .zero ? .minor : .mid
                ticks.append(tick)
            }
            self.ticks = ticks
        } else {
            self.ticks = [.major, .minor, .mid, .minor]
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
                .readSize { size in
                    let width = size.width
                    countUnits = Int((width / minWidthUnit).rounded(.up))
                    var range: [Duration] = []
                    let delta = timelineRange.upperBound - timelineRange.lowerBound
                    let stepSeconds = Int((delta.seconds / Double(countUnits)).rounded(.up))
                    for unit in 0...countUnits {
                        let duration: Duration = .seconds(stepSeconds * unit)
                        range.append(duration)
                    }
                    self.range = range
                }
            
            HStack(spacing: .zero) {
                ForEach(range, id: \.self) { seconds in
                    if range.last != seconds {
                        TimeUnit(ticks: ticks)
                            .stroke(.secondary, lineWidth: 1)
                            .overlay(alignment: .bottomLeading) {
                                Text(seconds.formatted(.timecode(frameRate: frameRate)))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, AppGrid.pt4)
                            }
                    }
                }
            }
            .frame(height: AppGrid.pt24)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var timelineRange: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(6)))
        
        var body: some View {
            TimescaleView(timelineRange: $timelineRange, frameRate: 25)
                .frame(width: AppGrid.pt140 * 3)
        }
    }
    
    return PreviewWrapper()
        .padding()
}
