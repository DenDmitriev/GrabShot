//
//  GrabCoordinator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

class Coordinator<Router: NavigationRouter>: NavigationCoordinator, ObservableObject {
    
    var childCoordinators: [any NavigationCoordinator] = []
    var route: Router
    weak var finishDelegate: NavigationCoordinatorFinishDelegate?
    
    @Published var path: NavigationPath = .init()
    
    @Published var sheet: Router?
    
    @Published var cover: Router?
    
    @Published var hasError: Bool = false
    
    var error: AppError?
    
    init(route: Router) {
        self.route = route
    }
    
    func push(_ page: Router) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(sheet: Router) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
        sheet = nil
    }
    
    func present(cover: Router) {
        self.cover = cover
    }
    
    func dismissCover() {
        cover = nil
    }
    
    func presentAlert(error: AppError) {
        self.error = error
        hasError = true
    }
    
    @ViewBuilder func build(_ route: Router) -> some View {
        if let coordinator = self as? Router.C {
            route.view(coordinator: coordinator)
        } else {
            EmptyView()
        }        
    }
    
    func buildViewModel(_ route: Router) -> (any ObservableObject)? {
        return nil
    }
}

extension Coordinator: NavigationCoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: any NavigationCoordinator) {
        childCoordinators = childCoordinators.filter({ coordinator in
            type(of: coordinator.route) != type(of: childCoordinator.route)
        })
    }
}
