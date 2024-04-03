//
//  LinkGrabCoordinatorView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.01.2024.
//

import SwiftUI

struct LinkGrabCoordinatorView: View {
    
    @StateObject var coordinator: LinkGrabCoordinator
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(.grab)
                .navigationTitle(LinkGrabRouter.grab.title)
                .navigationDestination(for: LinkGrabRouter.self) { route in
                    coordinator.build(route)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    coordinator.build(sheet)
                }
                .alert(isPresented: $coordinator.hasError,
                       error: coordinator.error
                ) { error in
                    Button("OK", role: .cancel) {}
                } message: { error in
                    if let text = error.recoverySuggestion { Text(text) }
                }
//                .fileExporter(
//                    isPresented: $coordinator.showVideoExporter,
//                    document: ExportDirectory(title: coordinator.videoStore[coordinator.contextVideoId].title),
//                    contentType: .directory,
//                    defaultFilename: coordinator.videoStore[coordinator.contextVideoId].title
//                ) { result in
//                    coordinator.fileExporter(result: result, for: coordinator.videoStore[coordinator.contextVideoId])
//                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    let imageStore = ImageStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let coordinator = LinkGrabCoordinator(imageStore: imageStore, scoreController: scoreController)
    
    return LinkGrabCoordinatorView(coordinator: coordinator)
}
