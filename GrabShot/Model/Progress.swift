//
//  Progress.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import Foundation

struct Progress {
    let current: Int
    let total: Int
    
    var percent: Double {
        Double(current) / Double(total) * 100
    }
    
    var status: String {
        "\(current)/\(total)"
    }
}
