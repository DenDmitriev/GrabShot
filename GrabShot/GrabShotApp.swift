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
        }
        .commands {
            CommandGroup(after: .newItem) {

                Button("Chouse Videos") {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = false
                    panel.allowedContentTypes = []
                    if panel.runModal() == .OK {
                        panel.urls.forEach { url in
                            if FileService.shared.isTypeVideoOk(url) {
                                let video = Video(url: url)
                                Session.shared.videos.append(video)
                            }
                        }
                    }
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
        }
        
        Settings {
            SettingsList()
        }
    }
}
