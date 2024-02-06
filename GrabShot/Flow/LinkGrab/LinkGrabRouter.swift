//
//  LinkGrabRouter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.01.2024.
//

import SwiftUI

enum LinkGrabRouter: NavigationRouter {
    case grab
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .grab:
            "Video link grab"
        }
    }
    
    func view(coordinator: LinkGrabCoordinator) -> some View {
        switch self {
        case .grab:
            LinkGrabView()
        }
    }
}
