//
//  GrabShotCommands.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI

struct GrabShotCommands: Commands {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @State private var showVideoImporter = false
    
    @State private var showImageImporter = false
    
    @Environment(\.openWindow) var openWindow
    @FocusedBinding(\.showRangePicker) private var showRangePicker
    @State private var selectedVideosIsEmpty: Bool = true
    
    let videoStore: VideoStore
    let imageStore: ImageStore
    let coordinator: any NavigationCoordinator
    
    init(coordinator: any NavigationCoordinator, videoStore: VideoStore, imageStore: ImageStore) {
        self.videoStore = videoStore
        self.imageStore = imageStore
        self.coordinator = coordinator
    }
    
    var body: some Commands {
        
        // MARK: - File tab
        
        CommandGroup(after: .newItem) {
            Button("Import Videos") {
                showVideoImporter.toggle()
            }
            .focusedSceneValue(\.showVideoImporter, $showVideoImporter)
            .keyboardShortcut("o", modifiers: [.command])
            .fileImporter(
                isPresented: $showVideoImporter,
                allowedContentTypes: FileService.utTypes,
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let success):
                    success.forEach { url in
                        let isTypeVideoOk = FileService.shared.isTypeVideoOk(url)
                        switch isTypeVideoOk {
                        case .success(_):
                            let video = Video(url: url, store: videoStore)
                            videoStore.addVideo(video: video)
                        case .failure(let failure):
                            videoStore.presentError(error: failure)
                        }
                    }
                case .failure(let failure):
                    if let failure = failure as? LocalizedError {
                        videoStore.presentError(error: failure)
                    }
                }
            }
            
            Button("Import Images") {
                showImageImporter.toggle()
            }
            .keyboardShortcut("i", modifiers: [.command])
            .fileImporter(
                isPresented: $showImageImporter,
                allowedContentTypes: [.image],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let success):
                    imageStore.insertImages(success)
                case .failure(let failure):
                    if let failure = failure as? LocalizedError {
                        videoStore.presentError(error: failure)
                    }
                }
            }
        }
        
        CommandGroup(replacing: CommandGroupPlacement.appInfo) {
            Button(action: {
                appDelegate.showAboutPanel()
            }) {
                Text(NSLocalizedString("About application GrabShot", comment: "Title"))
            }
        }
        
        // MARK: - Edit tab
        
        CommandGroup(after: .textEditing) {
            Button(String(localized: "Select range", comment: "Menu")) {
                guard let grabCoordinator = coordinator.childCoordinators.first(where: { type(of: $0) == GrabCoordinator.self }) as? GrabCoordinator,
                      let videoId = videoStore.selectedVideos.first
                else { return }
                grabCoordinator.present(sheet: .rangePicker(videoId: videoId))
            }
            .onReceive(videoStore.$selectedVideos, perform: { selectedVideos in
                selectedVideosIsEmpty = selectedVideos.isEmpty
            })
            .disabled(selectedVideosIsEmpty)
        }
        
        // MARK: - Window tab
        
        CommandGroup(after: .windowArrangement) {
            Button(String(localized: "Show metadata", comment: "Menu")) {
                let videoId = videoStore.selectedVideos.first
                let video = videoStore[videoId]
                if let metadata = video.metadata {
                    openWindow(id: WindowId.metadata.id, value: metadata)
                }
            }
            .disabled(selectedVideosIsEmpty)
        }
        
        CommandGroup(after: .windowArrangement) {
            Button(String(localized: "Show Overview", comment: "Menu")) {
                openWindow(id: WindowId.overview.id, value: WindowId.overview.id)
            }
            .keyboardShortcut("H")
        }
    }
}

