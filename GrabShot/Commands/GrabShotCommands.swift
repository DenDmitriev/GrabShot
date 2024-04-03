//
//  GrabShotCommands.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct GrabShotCommands: Commands {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var showImageImporter = false
    
    @Environment(\.openWindow) var openWindow
    @State private var selectedVideosIsEmpty: Bool = true
    private let pasteboard = NSPasteboard.general
    
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
                guard let grabCoordinator = coordinator.childCoordinators.first(where: { type(of: $0) == GrabCoordinator.self }) as? GrabCoordinator
                else { return }
                grabCoordinator.showFileImporter()
            }
            .keyboardShortcut("o", modifiers: [.command])
            
            Button("Import Video URL From Clipboard") {
                guard let stringURL = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespaces),
                      let url = URL(string: stringURL),
                      let grabCoordinator = coordinator.childCoordinators.first(where: { type(of: $0) == GrabCoordinator.self }) as? GrabCoordinator
                else {
                    let error = NetworkServiceError.invalidURL
                    videoStore.presentError(error: error)
                    return
                }
                switch url.scheme {
                case "file", nil:
                    videoStore.importVideo(result: .success([url]))
                default:
                    if FileService.shared.isExtensionVideoSupported(url) {
                        videoStore.importGlobalVideo(by: url)
                    } else {
                        grabCoordinator.videoHostingURL = url
                        grabCoordinator.hasVideoHostingURL.toggle()
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
                    let urls = success.compactMap { url in
                        url.startAccessingSecurityScopedResource() ? url : nil
                    }
                    imageStore.insertImages(urls)
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

