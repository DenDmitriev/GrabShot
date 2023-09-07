//
//  ContentView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var imageStore = ImageStore.shared
    @EnvironmentObject var session: Session
    @ObservedObject var coordinator: CoordinatorTab
    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow
    
    @AppStorage(UserDefaultsService.Keys.showOverview)
    var showOverview: Bool = true
    
    @State private var error: GrabShotError? = nil
    @State private var showAlert = false
    
    init() {
        coordinator = CoordinatorTab()
    }
    
    var body: some View {
        Group {
            switch coordinator.selectedTab {
            case .drop:
                coordinator.dropView
                    .tag(Tab.drop)
            case .grab:
                coordinator.grabView
                    .tag(Tab.grab)
            case .imageStrip:
                coordinator.imageStripView
                    .environmentObject(ImageStore.shared)
                    .tag(Tab.imageStrip)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                
                Picker("Picker", selection: $coordinator.selectedTab) {
                    Image(systemName: coordinator.selectedTab == Tab.drop ? Tab.drop.imageForSelected : Tab.drop.image)
                        .help("Drag&Drop video")
                        .tag(Tab.drop)
                    
                    
                    Image(systemName: coordinator.selectedTab == Tab.grab ? Tab.grab.imageForSelected : Tab.grab.image)
                        .help("Video grab")
                        .tag(Tab.grab)
                    
                    Image(systemName: coordinator.selectedTab == Tab.imageStrip ? Tab.imageStrip.imageForSelected : Tab.imageStrip.image)
                        .help("Image colors")
                        .tag(Tab.imageStrip)
                }
                .pickerStyle(.segmented)
                
            }
            
            ToolbarItem {
                Spacer()
            }
            
            ToolbarItem(placement: .automatic) {
                Button {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .help("Open settings")
            }
            
            ToolbarItem {
                Button {
                    openWindow(id: Window.overview.id)
                } label: {
                    Label("Overview", systemImage: "questionmark.circle")
                }
                .disabled(showOverview)
            }
        }
        .onChange(of: session.videos) { _ in
            if coordinator.selectedTab != .grab {
                coordinator.selectedTab = .grab
            }
        }
        .onChange(of: imageStore.imageStrips){ newValue in
            if coordinator.selectedTab != .imageStrip {
                coordinator.selectedTab = .imageStrip
            }
        }
        .alert(isPresented: $session.showAlert, error: session.error) { _ in
            Button("OK", role: .cancel) {
                print("alert dismiss")
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
        .alert(isPresented: $showAlert, error: error) { _ in
            Button("OK", role: .cancel) {
                print("alert dismiss")
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .alert(
            GrabCounter.alertTitle,
            isPresented: $session.showAlertDonate,
            presenting: session.grabCounter
        ) { grabCounter in
            Button("Donate 🍪") {
                session.syncGrabCounter(grabCounter)
                openURL(GrabCounter.donateURL)
            }
            Button("Cancel", role: .cancel) {
                session.syncGrabCounter(grabCounter)
            }
        } message: { grabCounter in
            Text(GrabCounter.alertMessage(count: grabCounter))
        }
        .frame(minWidth: Grid.minWidth, minHeight: Grid.minWHeight)
        .environmentObject(session)
        .navigationTitle(coordinator.selectedTab.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Session.shared)
    }
}
