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
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @Environment(\.openWindow)
    var openWindow
    
    @AppStorage(DefaultsKeys.showOverview)
    var showOverview: Bool = true
    
    @AppStorage(DefaultsKeys.openAppCount)
    private var openAppCount: Int = .zero
    
    var body: some Scene {
        let videoStore = VideoStore()
        let imageStore = ImageStore()
        
        WindowGroup("App", id: Window.app.id) { _ in
            ContentView(videoStore: videoStore, imageStore: imageStore)
                .environmentObject(imageStore)
                .environmentObject(videoStore)
                .onAppear {
                    if showOverview {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.default.delay(1)) {
                                openWindow(id: Window.overview.id, value: Window.overview.id)
                            }
                            
                        }
                    }
                    pushOpenAppCounter()
                }
        } defaultValue: {
            Window.app.id
        }
        .commandsRemoved()
        .defaultPosition(.center)
        .defaultSize(width: Grid.minWidth, height: Grid.minWHeight)
        .commands {
            GrabShotCommands(videoStore: videoStore, imageStore: imageStore)
            
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
                .disabled(videoStore.isGrabbing)
        }
        
        if #available(macOS 13.0, *) {
            MenuBarExtra {
                Button("Show GrabShot") {
                    openWindow(id: Window.app.id, value: Window.app.id)
                }
                .keyboardShortcut("G")
                
                Button("Show overview") {
                    openWindow(id: Window.overview.id, value: Window.overview.id)
                }
                .keyboardShortcut("H")
                
                Divider()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("Q")
            } label: {
                Image(nsImage: NSImage(named: "GrabShot")!)
            }
        }
    }
    
    func pushOpenAppCounter() {
        openAppCount += 1
    }
}

