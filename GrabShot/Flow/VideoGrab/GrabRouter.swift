//
//  GrabRouter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

enum GrabRouter: NavigationRouter {
    case grab
    case colorStrip(colors: [Color])
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .grab:
            "Video grab"
        case .colorStrip:
            "Color strip"
        }
    }
    
    func view(coordinator: GrabCoordinator) -> some View {
        switch self {
        case .grab:
            VideoGrabSidebar(viewModel: .build(store: coordinator.videoStore, score: coordinator.scoreController))
        case .colorStrip(let colors):
            StripView(colors: colors)
        }
    }
}
