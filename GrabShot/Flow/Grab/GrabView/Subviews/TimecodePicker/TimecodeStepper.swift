//
//  TimecodeStepper.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import SwiftUI

struct TimecodeStepper: View {
    
    @ObservedObject var timecode: Timecode
    
    var body: some View {
        HStack(spacing: Grid.pt8) {
            Stepper(value: $timecode.hour, in: 0...23) {
                TextField(TimecodeUnit.hour.string, value: $timecode.hour, formatter: HourNumberFormatter())
                    .frame(width: Grid.pt36)
            }
            Text(TimecodeUnit.hour.string)
            
            
            Stepper(value: $timecode.minute, in: 0...59) {
                TextField(TimecodeUnit.minute.string, value: $timecode.minute, formatter: MinuteNumberFormatter())
                    .frame(width: Grid.pt36)
            }
            Text(TimecodeUnit.minute.string)
            
            
            Stepper(value: $timecode.second, in: 0...59, step: 5) {
                TextField(TimecodeUnit.second.string, value: $timecode.second, formatter: SecondNumberFormatter())
                    .frame(width: Grid.pt36)
            }
            Text(TimecodeUnit.second.string)
        }
        
    }
}

struct TimecodeStepper_Previews: PreviewProvider {
    static var previews: some View {
        TimecodeStepper(timecode: .init(timeInterval: 4573))
            .previewLayout(.fixed(width: 400, height: 50))
    }
}

extension TimecodeStepper {
    
    enum TimecodeUnit {
        case hour, minute, second
        
        var string: String {
            let measurementFormatter: MeasurementFormatter = {
                let measurementFormatter = MeasurementFormatter()
                measurementFormatter.locale = Locale.current
                measurementFormatter.unitOptions = .providedUnit
                measurementFormatter.unitStyle = .short
                return measurementFormatter
            }()
            switch self {
            case .hour:
                return measurementFormatter.string(from: UnitDuration.hours)
            case .minute:
                return measurementFormatter.string(from: UnitDuration.minutes)
            case .second:
                return measurementFormatter.string(from: UnitDuration.seconds)
            }
        }
    }
}
