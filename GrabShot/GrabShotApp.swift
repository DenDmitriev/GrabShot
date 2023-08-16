//
//  GrabShotApp.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

@main
struct GrabShotApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(Session.shared)
        }
        .commands {
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
                                Session.shared.videos.append(video)
                            case .failure(let failure):
                                Session.shared.presentError(error: failure)
                            }
                        }
                    }
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
        }
        
        Settings {
            SettingsList()
                .disabled(Session.shared.isGrabbing)
        }
    }
}
