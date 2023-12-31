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
    
    @State
    private var showVideoImporter = false
    
    @State
    private var showImageImporter = false
    
    @Environment(\.openWindow)
    var openWindow
    
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Import Videos") {
                showVideoImporter.toggle()
            }
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
                            let video = Video(url: url)
                            VideoStore.shared.addVideo(video: video)
                        case .failure(let failure):
                            VideoStore.shared.presentError(error: failure)
                        }
                    }
                case .failure(let failure):
                    if let failure = failure as? LocalizedError {
                        VideoStore.shared.presentError(error: failure)
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
                    ImageStore.shared.insertImages(success)
                case .failure(let failure):
                    if let failure = failure as? LocalizedError {
                        VideoStore.shared.presentError(error: failure)
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
        
        CommandGroup(after: .windowArrangement) {
            Button("Show Overview") {
                openWindow(id: Window.overview.id, value: Window.overview.id)
            }
            .keyboardShortcut("H")
        }
    }
}

