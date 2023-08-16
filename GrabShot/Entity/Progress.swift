//
//  Progress.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import Foundation

struct Progress {
    var current: Int
    var total: Int
    
    init(current: Int = .zero, total: Int) {
        self.current = current
        self.total = total
    }
    
    var status: String {
        "\(current)/\(total)"
    }
}
