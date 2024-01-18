//
//  GrabCoordinatorView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

struct GrabCoordinatorView: View {
    
    @StateObject var coordinator: GrabCoordinator
    @Environment(\.openWindow) var openWindow
    
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
                .alert(isPresented: $coordinator.hasError,
                       error: coordinator.error
                ) { error in
                    Button("OK", role: .cancel) {}
                } message: { error in
                    if let text = error.failureReason { Text(text) }
                }
                .onReceive(coordinator.$showMetadata) { showMetadata in
                    if showMetadata, let metadata = coordinator.metadata {
                        openWindow(id: WindowId.metadata.id, value: metadata)
                    }
                }
                .onReceive(coordinator.$hasVideoHostingURL) { videoHostingURL in
                    guard videoHostingURL else { return }
                    Task {
                        await coordinator.hostingImporter(url: coordinator.videoHostingURL)
                    }
                }
                .fileImporter(isPresented: $coordinator.showVideoImporter,
                              allowedContentTypes: FileService.utTypes,
                              allowsMultipleSelection: true
                ) { result in
                    coordinator.fileImporter(result: result)
                }
                .fileExporter(
                    isPresented: $coordinator.showVideoExporter,
                    document: ExportDirectory(title: coordinator.videoStore[coordinator.contextVideoId].title),
                    contentType: .directory,
                    defaultFilename: coordinator.videoStore[coordinator.contextVideoId].title
                ) { result in
                    coordinator.fileExporter(result: result, for: coordinator.videoStore[coordinator.contextVideoId])
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: scoreController)
    
    return GrabCoordinatorView(coordinator: coordinator)
        .environmentObject(videoStore)
}
