//
//  ImageStripCoordinatorView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI

struct ImageStripCoordinatorView: View {
    
    @StateObject var coordinator: ImageStripCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(.sidebar)
                .navigationTitle(ImageStripRouter.sidebar.title)
                .navigationDestination(for: ImageStripRouter.self) { route in
                    coordinator.build(route)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    coordinator.build(sheet)
                }
                .alert(isPresented: $coordinator.hasError,
                       error: coordinator.error
                ) {
                    Button("OK", role: .cancel) {}
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    let imageStore = ImageStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let coordinator = ImageStripCoordinator(imageStore: imageStore, scoreController: scoreController)
    
    return ImageStripCoordinatorView(coordinator: coordinator)
        .environmentObject(imageStore)
}
