//
//  GrabShotCommands.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI


struct GrabShotCommands: Commands {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Choose Videos") {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = true
                panel.canChooseFiles = true
                panel.canChooseDirectories = false
                panel.allowedContentTypes = []
                if panel.runModal() == .OK {
                    panel.urls.forEach { url in
                        let result = FileService.shared.isTypeVideoOk(url)
                        switch result {
                        case .success(_):
                            let video = Video(url: url)
                            Session.shared.addVideo(video: video)
                        case .failure(let failure):
                            Session.shared.presentError(error: failure)
                        }
                    }
                }
            }
            .keyboardShortcut("o", modifiers: [.command])
        }
        
        CommandGroup(replacing: CommandGroupPlacement.appInfo) {
            Button(action: {
                appDelegate.showAboutPanel()
            }) {
                Text(NSLocalizedString("About application GrabShot", comment: "Title"))
            }
        }
    }
}

