//
//  GrabShotCommands.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI


struct GrabShotCommands: Commands {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showImporter = false
    
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Choose Videos") {
                showImporter.toggle()
            }
            .keyboardShortcut("o", modifiers: [.command])
            .fileImporter(
                isPresented: $showImporter,
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
                            Session.shared.addVideo(video: video)
                        case .failure(let failure):
                            Session.shared.presentError(error: failure)
                        }
                    }
                case .failure(let failure):
                    if let failure = failure as? LocalizedError {
                        Session.shared.presentError(error: failure)
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
    }
}

