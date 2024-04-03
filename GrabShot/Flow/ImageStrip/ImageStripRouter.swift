//
//  ImageStripRouter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI

enum ImageStripRouter: NavigationRouter {
    case sidebar
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .sidebar:
            String(localized: "Images")
        }
    }
    
    func view(coordinator: ImageStripCoordinator) -> some View {
        switch self {
        case .sidebar:
            ImageSidebar(viewModel: coordinator.buildViewModel(self) as! ImageSidebarModel)
        }
    }
}
