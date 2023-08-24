//
//  RangeType.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import Foundation

enum RangeType: Int, CaseIterable, Identifiable {
    case full
    case excerpt
    
    var id: Self {
        self
    }
    
    var label: String {
        let comment = "Label"
        switch self {
        case .full:
            return NSLocalizedString("Full", comment: comment)
        case .excerpt:
            return NSLocalizedString("Excerpt", comment: comment)
        }
    }
    
    var image: String {
        switch self {
        case .full:
            return "arrow.left.and.right"
        case .excerpt:
            return "arrow.right.and.line.vertical.and.arrow.left"
        }
    }
    
    var tag: Int {
        self.rawValue
    }
}
