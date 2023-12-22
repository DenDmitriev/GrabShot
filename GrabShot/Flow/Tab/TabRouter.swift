//
//  AppRouter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

enum TabRouter: NavigationRouter {
    case grab
    case imageStrip
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .grab:
            "Video grab"
        case .imageStrip:
            "Image colors"
        }
    }
    
    var image: String {
        switch self {
        case .grab:
            return "film.stack"
        case .imageStrip:
            return "photo.stack"
        }
    }
    
    var imageForSelected: String {
        switch self {
        case .grab:
            return "film.stack.fill"
        case .imageStrip:
            return "photo.stack.fill"
        }
    }
    
    @ViewBuilder func view(coordinator: TabCoordinator) -> some View {
        switch self {
        case .grab:
            if let grabCoordinator = buildCoordinator(in: coordinator) as? GrabCoordinator {
                GrabCoordinatorView(coordinator: grabCoordinator)
            } else {
                EmptyView()
            }
        case .imageStrip:
            ImageSidebar(viewModel: coordinator.buildViewModel(self) as! ImageSidebarModel)
        }
    }
    
    private func buildCoordinator(in parent: TabCoordinator) -> (any NavigationCoordinator)? {
        switch self {
        case .grab:
            let grabCoordinator = GrabCoordinator(videoStore: parent.videoStore, scoreController: parent.scoreController)
            grabCoordinator.finishDelegate = parent
            parent.childCoordinators.append(grabCoordinator)
            return grabCoordinator
        case .imageStrip:
            return nil
        }
    }
}
