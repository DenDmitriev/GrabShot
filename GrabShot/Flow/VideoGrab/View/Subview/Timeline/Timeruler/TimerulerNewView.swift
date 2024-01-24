//
//  TimerulerView.swift
//  Timeruler
//
//  Created by Denis Dmitriev on 21.01.2024.
//

import SwiftUI

struct TimerulerNewView: View {
    @Binding var frameRate: Double
    @Binding var range: ClosedRange<Duration>
    @State var scaleMode: ScaleMode? = nil
    @State private var rulerData: [Int] = []
    @State private var size: CGSize = .zero
    private static let minWidthUnit: CGFloat = 6
    
    var body: some View {
        VStack {
            switch scaleMode {
            case .frame:
                HStack(spacing: .zero) {
                    let units = Int(frameRate.rounded(.up))
                    
                    ForEach(rulerData, id: \.self) { second in
                        let duration: Duration = .seconds(second)
                        let timecode = duration.formatted(.timecode(frameRate: frameRate))
                        
                        if second == rulerData.last {
                            // Подрежем хвост если длина видео не целая
                            let widthSecond = size.width / (range.upperBound.seconds - range.lowerBound.seconds)
                            let seconds = range.upperBound.seconds.rounded(.up) - range.upperBound.seconds
                            let cropLastWidth = seconds * widthSecond
                            let widthLast = widthSecond - cropLastWidth
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                RulerUnitView(units: units, label: timecode)
                                    .frame(width: widthSecond)
                            }
                            .frame(width: widthLast, alignment: .trailing)
                            .scrollDisabled(true)
                        } else {
                            RulerUnitView(units: units, label: timecode)
                        }
                    }
                }
            case .seconds(let interval):
                HStack(spacing: .zero) {
                    let units = 24
                    
                    ForEach(rulerData, id: \.self) { second in
                        let duration: Duration = .seconds(second)
                        let timecode = duration.formatted(.timecode(frameRate: frameRate))
                        
                        if second == rulerData.last {
                            // Подрежем хвост если длина видео не целая
                            // Кол-во полных отрезков
                            let fullUnitsCount = ((range.upperBound.seconds - range.lowerBound.seconds) / CGFloat(interval))
                            // Длина полного юнита
                            let widthSecondInterval = size.width / fullUnitsCount
                            // Остаток в секундах от полного юнита
                            let secondsLast = Int(fullUnitsCount * CGFloat(interval)) % interval
                            // Длина не полного юнита
                            let widthLastUnit = CGFloat(secondsLast) / CGFloat(interval) * widthSecondInterval
                            
                            if secondsLast == .zero {
                                RulerUnitView(units: units, label: timecode)
                                    .frame(width: widthSecondInterval)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    RulerUnitView(units: units, label: timecode)
                                        .frame(width: widthSecondInterval)
                                }
                                .frame(width: widthLastUnit, alignment: .trailing)
                                .scrollDisabled(true)
                            }
                        } else {
                            RulerUnitView(units: units, label: timecode)
                        }
                    }
                }
            case nil:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .readSize(onChange: { size in
            self.size = size
            let scaleMode = calculateScaleMode(frameRate: frameRate, width: size.width, range: range)
            self.scaleMode = scaleMode
            
        })
        .onChange(of: range) { newRange in
            self.scaleMode = calculateScaleMode(frameRate: frameRate, width: size.width, range: newRange)
        }
        .onChange(of: scaleMode) { newScaleMode in
            if let newScaleMode {
                self.rulerData = rulerData(range: range, scale: newScaleMode)
            }
        }
        .frame(height: AppGrid.pt36)
    }
    
    
    private func calculateScaleMode(frameRate: Double, width: CGFloat, range: ClosedRange<Duration>) -> ScaleMode {
        guard width > .zero else { return .frame }
        
        // Длина всей линейки
        let totalSeconds = (range.upperBound.seconds - range.lowerBound.seconds)
        let totalFrames = totalSeconds * frameRate
        let widthForUnit = width / totalFrames
        let scaleMode: ScaleMode
        if widthForUnit > Self.minWidthUnit {
            // Если масштаб больше секунды делим шкалу по 1 секунде
            scaleMode = .frame
        } else {
            // Если масштаб меньше секунды делим шкалу по несколько четных 3м секунд
            // Масштаб на текущую длину
            let scale = Self.minWidthUnit / width // 1 : 100
            // Шаг в секундах. Округляем вверх чтоб длина одного штриха не стала меньше чем нужно
            var interval = Int((totalSeconds * scale).rounded(.up))
            // Приводим к целому делителю времени на 3 в сторону увеличения для красивого отображения времени
            interval = interval + (3 - (interval % 3))
            // Рассчитаем для данного интервала получившеюся длину
            var widthForUnit = width / (totalSeconds / Double(interval))
            // Мы стремимся к длине интервала. Чтоб поместился лейбл метки
            let widthForUnitTarget = Self.minWidthUnit * 24
            
            // Если целевой интервал больше то умножим интервал на коэфициент между длинами
            if widthForUnit < widthForUnitTarget {
                let factor = (widthForUnitTarget / widthForUnit).rounded(.up)
                interval = Int(factor) * interval
                widthForUnit = width / (totalSeconds / Double(interval))
                
                // Так как мы округляли вверх то нужно точнее рассчитать
                // Будем уменьшать интервал на 3 пока не станем ближе к цели цели
                while widthForUnit > widthForUnitTarget {
                    interval -= 3
                    widthForUnit = width / (totalSeconds / Double(interval))
                }
            }
            
            scaleMode = .seconds(interval: interval)
        }
        
        return scaleMode
    }
    
    private func rulerData(range: ClosedRange<Duration>, scale mode: ScaleMode) -> [Int] {
        let from = Int(range.lowerBound.seconds.rounded(.down))
        let to = Int(range.upperBound.seconds.rounded(.up)) - 1
        
        switch scaleMode {
        case .frame:
            return Array(from...to)
        case .seconds(let interval):
            var scaleRange: [Int] = []
            for second in stride(from: from, to: to, by: interval) {
                scaleRange.append(second)
            }
            return scaleRange
        case nil:
            return Array()
        }
    }
}

extension TimerulerNewView {
    enum ScaleMode: Equatable {
        /// Масштаб в одной секунде
        /// Кол-во делений в единице масштаба равно числу кадров в секунде
        case frame
        /// Масштаб в нескольких секундах
        /// - Parameters:
        ///   - interval: Интервал по масштабу в секундах.
        ///   Каждый интервал будет делится на 24 части
        case seconds(interval: Int)
    }
}

#Preview {
    VStack {
        TimerulerNewView(
            frameRate: .constant(24),
            range: .constant(.init(uncheckedBounds: (
                lower: .seconds(0),
                upper: .seconds(3.5))
            )))
        .frame(width: 500, height: 40)
        
        TimerulerNewView(
            frameRate: .constant(24),
            range: .constant(.init(uncheckedBounds: (
                lower: .seconds(0),
                upper: .seconds(6000))
            )))
        .frame(width: 500, height: 40)
    }
    .padding()
}
