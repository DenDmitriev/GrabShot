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
    
    @AppStorage(UserDefaultsService.Keys.showOverview)
    var showOverview: Bool = true
    
    @State
    private var window: NSWindow?
    
    var body: some Scene {
        WindowGroup("App", uniqueWindow: Window.app) {
            ContentView()
                .environmentObject(Session.shared)
                .onAppear {
                    self.openWindow(Window.overview)
//                    if showOverview {
//                        self.openWindow(Window.overview)
//                    }
                }
        }
//        .windowToolbarStyle(.unified)
        .onChange(of: showOverview, perform: { showOverview in
            if !showOverview {
                self.openWindow(Window.app)
            }
        })
        .commands {
            GrabShotCommands()
            SidebarCommands()
        }
        .commands {
            CommandGroup(after: .windowArrangement) {
                Button("Show Overview") {
                    showOverview = true
                    self.openWindow(Window.overview)
                }
                .keyboardShortcut("P")
            }
        }
        
        WindowGroup("Overview", uniqueWindow: Window.overview) {
            OnboardingView(pages: OnboardingPage.fullOnboarding)
                .frame(maxWidth: Grid.pt600, maxHeight: Grid.pt600)
                .background(VisualEffectView().ignoresSafeArea())
                .background(WindowAccessor(window: self.$window))
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        
        Settings {
            SettingsList()
                .disabled(Session.shared.isGrabbing)
        }
    }
}

