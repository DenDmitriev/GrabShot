//
//  BorderNumberFormatter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 02.05.2024.
//

import Foundation

class BorderNumberFormatter: NumberFormatter {

    override init() {
        super.init()
        numberStyle = .none
        maximum = 99
        minimum = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
