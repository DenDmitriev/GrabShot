//
//  ResolutionNumberFormatter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import Foundation

class ResolutionNumberFormatter: NumberFormatter {

    override init() {
        super.init()
        numberStyle = .none
        maximum = 3840
        minimum = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
