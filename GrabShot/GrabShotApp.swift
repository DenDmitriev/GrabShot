//
//  GrabShotApp.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

@main
struct GrabShotApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(Session.shared)
        }
        .commands {
            GrabShotCommands()
            SidebarCommands()
        }
        
        Settings {
            SettingsList()
                .disabled(Session.shared.isGrabbing)
        }
    }
}
