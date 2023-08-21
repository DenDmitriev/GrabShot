//
//  Progress.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import Foundation

class Progress: ObservableObject {
    @Published var current: Int
    @Published var total: Int
    
    init(current: Int = .zero, total: Int) {
        self.current = current
        self.total = total
    }
    
    var status: String {
        "\(current)/\(total)"
    }
}
