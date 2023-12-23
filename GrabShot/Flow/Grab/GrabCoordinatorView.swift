//
//  GrabCoordinatorView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

struct GrabCoordinatorView: View {
    
    @StateObject var coordinator: GrabCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(.grab)
                .navigationTitle(GrabRouter.grab.title)
                .navigationDestination(for: GrabRouter.self) { route in
                    coordinator.build(route)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    coordinator.build(sheet)
                }
                .fileImporter(isPresented: $coordinator.showVideoImporter,
                              allowedContentTypes: FileService.utTypes,
                              allowsMultipleSelection: true
                ) { result in
                    coordinator.fileImporter(result: result)
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
    let videoStore = VideoStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    
    return GrabCoordinatorView(coordinator: GrabCoordinator(videoStore: videoStore, scoreController: scoreController))
}
