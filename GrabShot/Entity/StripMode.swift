//
//  StripMode.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2023.
//

import Foundation

enum StripMode: Int, Identifiable, CaseIterable {
    case strip, gradient
    
    var id: Int {
        self.rawValue
    }
    
    var name: String {
        switch self {
        case .strip:
            return NSLocalizedString("Strip", comment: "Settings")
        case .gradient:
            return NSLocalizedString("Gradient", comment: "Settings")
        }
    }
}
