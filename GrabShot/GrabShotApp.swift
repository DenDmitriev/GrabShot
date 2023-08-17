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
            GrabShotCommands()
        }
        
        Settings {
            SettingsList()
                .disabled(Session.shared.isGrabbing)
        }
    }
}
