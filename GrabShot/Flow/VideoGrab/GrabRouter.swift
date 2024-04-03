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
            String(localized: "Video")
        case .colorStrip:
            String(localized: "Color strip")
        }
    }
    
    func view(coordinator: GrabCoordinator) -> some View {
        switch self {
        case .grab:
            if let viewModel = coordinator.viewModel(type: VideoGrabSidebarModel.self, for: self) {
                VideoGrabSidebar(viewModel: viewModel)
            }
            
        case .colorStrip(let colors):
            StripView(colors: colors)
        }
    }
}
