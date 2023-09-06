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
    
    @Environment(\.openWindow)
    var openWindow
    
    @Environment(\.dismiss)
    var dismiss
    
//    @State
//    private var window: NSWindow?
    
    @AppStorage(UserDefaultsService.Keys.showOverview)
    var showOverview: Bool = false
    
    var body: some Scene {
        WindowGroup("App", id: Window.app.id) {
            ContentView()
                .environmentObject(Session.shared)
                .onAppear {
//                    openWindow(id: Window.overview.id)
                }
        }
        .commands {
            GrabShotCommands()
            SidebarCommands()
        }
        .commands {
            CommandGroup(after: .windowArrangement) {
                Button("Show Overview") {
                    openWindow(id: Window.overview.id)
                }
                .keyboardShortcut("P")
                .disabled(showOverview)
            }
        }
        
        WindowGroup("Overview", id: Window.overview.id) {
            OnboardingView(pages: OnboardingPage.fullOnboarding)
                .frame(maxWidth: Grid.minWidthOverview, maxHeight: Grid.minWHeightOverview)
                .background(VisualEffectView().ignoresSafeArea())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        
        Settings {
            SettingsList()
                .disabled(Session.shared.isGrabbing)
        }
    }
}

