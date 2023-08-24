//
//  SecondNumberFormatter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import Foundation


class SecondNumberFormatter: NumberFormatter {
    override init() {
        super.init()
        numberStyle = .none
        maximum = 59
        minimum = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
