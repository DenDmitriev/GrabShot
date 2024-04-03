//
//  AppRouter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

enum TabRouter: NavigationRouter {
    case videoGrab
    case videoLinkGrab
    case imageStrip
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .imageStrip:
            String(localized: "Image")
        case .videoLinkGrab:
            String(localized: "Video link grab")
        case .videoGrab:
            String(localized: "Video")
        }
    }
    
    var image: String {
        switch self {
        case .imageStrip:
            return "photo.stack"
        case .videoGrab:
            return "play.square.stack"
        case .videoLinkGrab:
            return "LinkVideoStack"
        }
    }
    
    var imageForSelected: String {
        switch self {
        case .imageStrip:
            return "photo.stack.fill"
        case .videoGrab:
            return "play.square.stack.fill"
        case .videoLinkGrab:
            return "LinkVideoStackFill"
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
        case .videoLinkGrab:
            if let linkGrabCoordinator = buildCoordinator(in: coordinator) as? LinkGrabCoordinator {
                LinkGrabCoordinatorView(coordinator: linkGrabCoordinator)
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
        case .videoLinkGrab:
            if let linkGrabCoordinator = parent.childCoordinators.first(where: { type(of: $0) == LinkGrabCoordinator.self }) {
                return linkGrabCoordinator
            } else {
                let linkGrabCoordinator = LinkGrabCoordinator(imageStore: parent.imageStore, scoreController: parent.scoreController)
                linkGrabCoordinator.finishDelegate = parent
                parent.childCoordinators.append(linkGrabCoordinator)
                return linkGrabCoordinator
            }
        }
    }
}
