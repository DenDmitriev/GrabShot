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
        // TODO: Create builder
        let videoStore = VideoStore()
        let imageStore = ImageStore()
        let caretaker = Caretaker()
        let scoreController = ScoreController(caretaker: caretaker)
        let coordinator = CoordinatorTab(videoStore: videoStore, imageStore: imageStore, scoreController: scoreController)
        
        WindowGroup("App", id: WindowId.app.id) { _ in
            ContentView()
                .environmentObject(coordinator)
                .environmentObject(imageStore)
                .environmentObject(videoStore)
                .environmentObject(scoreController)
                .onAppear {
//                    resetScore()
                    
                    if showOverview {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.default.delay(1)) {
                                openWindow(id: WindowId.overview.id, value: WindowId.overview.id)
                            }
                            
                        }
                    }
                    pushOpenAppCounter()
                }
        } defaultValue: {
            WindowId.app.id
        }
        .commandsRemoved()
        .defaultPosition(.center)
        .defaultSize(width: Grid.minWidth, height: Grid.minWHeight)
        .commands {
            GrabShotCommands(videoStore: videoStore, imageStore: imageStore)
            
            SidebarCommands()
        }
        
        WindowGroup("Overview", id: WindowId.overview.id) { _ in
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
            WindowId.overview.id
        }
        .keyboardShortcut("H")
        .defaultPosition(.center)
        .defaultSize(width: Grid.minWidthOverview, height: Grid.minWHeightOverview)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        WindowGroup(id: WindowId.metadata.id, for: MetadataVideo.self) { $metadata in
            MetadataView(metadata: metadata)
        }
        
        Settings {
            SettingsList(viewModel: SettingsModel())
                .navigationTitle("Settings")
                .disabled(videoStore.isGrabbing)
        }
        
        if #available(macOS 13.0, *) {
            MenuBarExtra {
                Button("Show GrabShot") {
                    openWindow(id: WindowId.app.id, value: WindowId.app.id)
                }
                .keyboardShortcut("G")
                
                Button("Show overview") {
                    openWindow(id: WindowId.overview.id, value: WindowId.overview.id)
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
    
    private func pushOpenAppCounter() {
        openAppCount += 1
    }
    
    private func resetScore() {
        UserDefaultsService.default.grabCount = .zero
        UserDefaultsService.default.colorExtractCount = .zero
        showOverview = true
        openAppCount = .zero
    }
}

