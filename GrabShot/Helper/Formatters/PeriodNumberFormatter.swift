//
//  PeriodNumberFormatter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import Foundation

class PeriodNumberFormatter: NumberFormatter {

    override init() {
        super.init()
        numberStyle = .none
        maximum = 300
        minimum = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


