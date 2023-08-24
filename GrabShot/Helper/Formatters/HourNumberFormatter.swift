//
//  HourNumberFormatter.swift
//  
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import Foundation

class HourNumberFormatter: NumberFormatter {
    override init() {
        super.init()
        numberStyle = .none
        maximum = 23
        minimum = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
