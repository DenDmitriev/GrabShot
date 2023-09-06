//
//  GrabShotApp.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//
//  https://swiftwithmajid.com/2022/11/02/window-management-in-swiftui/

import SwiftUI

@main
struct GrabShotApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.openWindow)
    var openWindow
    
    @AppStorage(UserDefaultsService.Keys.showOverview)
    var showOverview: Bool = true
    
    var body: some Scene {
        WindowGroup("App", id: Window.app.id) { _ in
            ContentView()
                .environmentObject(Session.shared)
                .onAppear {
                    if showOverview {
                        openWindow(id: Window.overview.id)
                    }
                }
        } defaultValue: {
            Window.app.id
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
                .keyboardShortcut("H")
                .disabled(showOverview)
            }
        }
        
        WindowGroup("Overview", id: Window.overview.id) { _ in
            OnboardingView(pages: OnboardingPage.fullOnboarding)
                .frame(maxWidth: Grid.minWidthOverview, maxHeight: Grid.minWHeightOverview)
                .background(VisualEffectView().ignoresSafeArea())
                .onAppear {
                    showOverview = true
                }
                .onDisappear {
                    showOverview = false
                }
        } defaultValue: {
            Window.overview.id
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        
        Settings {
            SettingsList()
                .navigationTitle("Settings")
                .disabled(Session.shared.isGrabbing)
        }
    }
}

