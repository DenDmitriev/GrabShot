//
//  Window.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import Foundation

enum Window: String, Identifiable {
    case overview
    case app
    
    var id: String {
        self.rawValue
    }
}
