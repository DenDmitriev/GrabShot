//
//  Tab.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case drop
    case grab
    case imageStrip
    
    var id: String {
        return self.rawValue
    }
    
    var title: String {
        switch self {
        case .drop:
            return NSLocalizedString("Drop Video", comment: "Tab title")
        case .grab:
            return NSLocalizedString("Grab Queue", comment: "Tab title")
        case .imageStrip:
            return NSLocalizedString("Image Strip", comment: "Tab title")
        }
    }
    
    var image: Image {
        switch self {
        case .drop:
            return Image(systemName: "arrow.down.app")
        case .grab:
            return Image(systemName: "tablecells")
        case .imageStrip:
            return Image(systemName: "photo")
        }
    }
}
