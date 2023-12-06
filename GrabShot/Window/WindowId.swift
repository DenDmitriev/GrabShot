//
//  Window.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import Foundation

enum WindowId: String, Identifiable {
    case overview
    case app
    case properties
    
    var id: String {
        self.rawValue
    }
}
