//
//  GrabShotApp.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//
//  https://swiftwithmajid.com/2022/11/02/window-management-in-swiftui/
//  https://www.fline.dev/window-management-on-macos-with-swiftui-4/

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
                .environmentObject(VideoStore.shared)
                .onAppear {
                    if showOverview {
                        openWindow(id: Window.overview.id, value: Window.overview.id)
                    }
                }
        } defaultValue: {
            Window.app.id
        }
        .commandsRemoved()
        .defaultPosition(.center)
        .defaultSize(width: Grid.minWidth, height: Grid.minWHeight)
        .commands {
            GrabShotCommands()
            SidebarCommands()
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
        .keyboardShortcut("H")
        .defaultPosition(.center)
        .defaultSize(width: Grid.minWidthOverview, height: Grid.minWHeightOverview)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)


        Settings {
            SettingsList()
                .navigationTitle("Settings")
                .disabled(VideoStore.shared.isGrabbing)
        }
    }
}

