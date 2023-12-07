//
//  HertzFormatStyle.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.12.2023.
//

import Foundation

struct HertzFormatStyle: FormatStyle {
    func format(_ value: Int) -> String {
        let symbol: String = {
            let identifier = Locale.current.identifier
            print(identifier)
            switch identifier {
            case "ru_RU":
                return "Гц"
            default:
                return "Hz"
            }
        }()
        
        return value.formatted() + " " + symbol
    }
}

extension FormatStyle where Self == HertzFormatStyle {
  static var hertz: HertzFormatStyle { .init() }
}
