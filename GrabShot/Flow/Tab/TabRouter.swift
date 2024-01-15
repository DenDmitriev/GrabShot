//
//  AppRouter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

enum TabRouter: NavigationRouter {
    case videoGrab
    case imageStrip
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .imageStrip:
            "Image colors"
        case .videoGrab:
            "Video grab"
        }
    }
    
    var image: String {
        switch self {
        case .imageStrip:
            return "photo.stack"
        case .videoGrab:
            return "film.stack"
        }
    }
    
    var imageForSelected: String {
        switch self {
        case .imageStrip:
            return "photo.stack.fill"
        case .videoGrab:
            return "film.stack.fill"
        }
    }
    
    @ViewBuilder func view(coordinator: TabCoordinator) -> some View {
        switch self {
        case .videoGrab:
            if let grabCoordinator = buildCoordinator(in: coordinator) as? GrabCoordinator {
                GrabCoordinatorView(coordinator: grabCoordinator)
            } else {
                EmptyView()
            }
        case .imageStrip:
            if let imageStripCoordinator = buildCoordinator(in: coordinator) as? ImageStripCoordinator {
                ImageStripCoordinatorView(coordinator: imageStripCoordinator)
            } else {
                EmptyView()
            }
        }
    }
    
    private func buildCoordinator(in parent: TabCoordinator) -> (any NavigationCoordinator)? {
        switch self {
        case .imageStrip:
            if let imageStripCoordinator = parent.childCoordinators.first(where: { type(of: $0) == ImageStripCoordinator.self }) {
                return imageStripCoordinator
            } else {
                let imageStripCoordinator = ImageStripCoordinator(imageStore: parent.imageStore, scoreController: parent.scoreController)
                imageStripCoordinator.finishDelegate = parent
                parent.childCoordinators.append(imageStripCoordinator)
                return imageStripCoordinator
            }
        case .videoGrab:
            if let grabCoordinator = parent.childCoordinators.first(where: { type(of: $0) == GrabCoordinator.self }) {
                return grabCoordinator
            } else {
                let grabCoordinator = GrabCoordinator(videoStore: parent.videoStore, imageStore: parent.imageStore, scoreController: parent.scoreController)
                grabCoordinator.finishDelegate = parent
                parent.childCoordinators.append(grabCoordinator)
                return grabCoordinator
            }
        }
    }
}
