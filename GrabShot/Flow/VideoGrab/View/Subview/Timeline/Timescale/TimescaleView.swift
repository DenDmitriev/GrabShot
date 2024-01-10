//
//  TimescaleView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct TimescaleView: View {
    
    enum TickMode {
        case frame(frameRate: Double), seconds
        var countForTicks: Int {
            switch self {
            case .frame(let frameRate):
                return Int(frameRate.rounded())
            case .seconds:
                return 24
            }
        }
    }
    
    @Binding var timelineRange: ClosedRange<Duration>
    let frameRate: Double
    @State private var countForTicks: Int = 24
    @State private var size: CGSize = .zero
    @State private var ticks: [TimeTick] = [.major]
    @State private var tailTicks: [TimeTick] = []
    @State private var unitStep: CGFloat = .zero
    @State private var unitWidth: CGFloat = .zero
    private let minWidthUnit: CGFloat = AppGrid.pt6
    @State private var scaleRange: [Duration] = []
    @State private var tickMode: TickMode?
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
                .readSize { size in
                    self.size = size
                    buildScale(for: size.width)
                }
            
            HStack(spacing: .zero) {
                let stepSeconds: Duration = .seconds(unitStep / frameRate)
                ForEach(scaleRange, id: \.self) { seconds in
                    HStack(spacing: .zero) {
                        if (seconds + stepSeconds) <= timelineRange.upperBound {
                            // Рисуем полную размерную единицу
                            TimeUnits(ticks: [.major])
                                .stroke(gradient, lineWidth: 1)
                                .frame(maxWidth: unitWidth)
                            
                            TimeUnits(ticks: ticks)
                                .stroke(style, lineWidth: 1)
                                .frame(maxWidth: unitWidth * (frameRate - 1))
                        } else {
                            // Рисуем не полную размерную единицу
                            if !tailTicks.isEmpty {
                                TimeUnits(ticks: [.major])
                                    .stroke(gradient, lineWidth: 1)
                                    .frame(maxWidth: unitWidth)
                                
                                TimeUnits(ticks: tailTicks)
                                    .stroke(style, lineWidth: 1)
                                    .frame(maxWidth: unitWidth * CGFloat(tailTicks.count - 1))
                            }
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        unitMark(duration: seconds)
                    }
                }
            }
            .frame(height: AppGrid.pt24)
        }
    }
    
    func unitMark(duration: Duration) -> some View {
        Text(duration.formatted(.timecode(frameRate: frameRate)))
            .font(.caption2)
            .foregroundColor(.secondary.opacity(0.5))
            .padding(.leading, AppGrid.pt4)
    }
    
    private func buildScale(for width: CGFloat) {
        // Длина всей линейки
        let scaleFrames = (timelineRange.upperBound.seconds - timelineRange.lowerBound.seconds) * frameRate
        
        // Посчитаем шаг для линейки в секундах и считаем длину шага в пикселях
        let unitStep: CGFloat
        if (width / scaleFrames) > minWidthUnit {
            // Если масштаб больше секунды делим шкалу по 1 секунде
            tickMode = .frame(frameRate: frameRate)
            unitStep = frameRate
            unitWidth = width / scaleFrames
        } else {
            // Если масштаб меньше секунды делим шкалу на несколько секунд
            tickMode = .seconds
            let step = (width / minWidthUnit).round(to: 2)
            unitStep = (scaleFrames / step).rounded(.down) * frameRate
            unitWidth = (width / scaleFrames) * unitStep / frameRate
        }
        self.unitStep = unitStep
        
        // Теперь создадим шкалу массив для линейки и деления между ними
        var scaleRange: [Duration] = []
        for frames in stride(from: 0.0, to: scaleFrames, by: unitStep) {
            let seconds = frames / frameRate
            scaleRange.append(timelineRange.lowerBound + .seconds(seconds))
        }
        
        countForTicks = tickMode?.countForTicks ?? Int(frameRate)
        
        self.ticks = buildTicks(count: countForTicks)
        self.scaleRange = scaleRange
        
        // Наконец хвост линейки для не полного шага
        // Посчитаем сколько секунд осталось нарисовать
        let tailUnits = scaleFrames - unitStep * Double(scaleRange.count - 1)
        // Посчитаем кол-во делений для хвоста
        let tailTicksCount: Int = Int(tailUnits / unitStep * Double(countForTicks))
        
        self.tailTicks = buildTicks(count: tailTicksCount)
    }
    
    // Создаем тики между шагами
    private func buildTicks(count: Int) -> [TimeTick] {
        guard count != .zero else { return [] }
        let isEven = count % 2 == .zero
        var ticks: [TimeTick] = []
        for (index, tick) in (1..<count).enumerated() {
            switch tick % 2 == .zero {
            case true where isEven && index == count / 2 - 1:
                ticks.append(.half)
            case true:
                ticks.append(.mid)
            case false:
                ticks.append(.minor)
                
            }
        }
        print(ticks.count)
        return ticks
    }
    
    // Цвет для линии
    let style: HierarchicalShapeStyle = .quaternary
    
    let gradient: LinearGradient = .linearGradient(.init(colors: [.secondary.opacity(0.75), .clear]), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 1, y: 1))
}

#Preview {
    struct PreviewWrapper: View {
        @State var timelineRange: ClosedRange<Duration> = .init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(10.5)))
        
        var body: some View {
            TimescaleView(timelineRange: $timelineRange, frameRate: 24)
                .frame(width: 300, height: 10)
        }
    }
    
    return PreviewWrapper()
        .padding()
}
