//
//  ContentView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @StateObject var imageStore = ImageStore.shared
    @EnvironmentObject var videoStore: VideoStore
    @ObservedObject var coordinator: CoordinatorTab
    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow
    @Environment(\.requestReview) var requestReview
    
    @AppStorage(UserDefaultsService.Keys.showOverview)
    var showOverview: Bool = true
    
    @State private var error: GrabShotError? = nil
    @State private var showAlert = false
    @State private var showAlertDonate = false
    
    init() {
        coordinator = CoordinatorTab()
    }
    
    var body: some View {
        Group {
            switch coordinator.selectedTab {
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
        .onChange(of: videoStore.videos) { _ in
            if coordinator.selectedTab != .grab {
                coordinator.selectedTab = .grab
            }
        }
        .onChange(of: imageStore.imageStrips){ newValue in
            if coordinator.selectedTab != .imageStrip {
                coordinator.selectedTab = .imageStrip
            }
        }
        .alert(isPresented: $videoStore.showAlert, error: videoStore.error) { _ in
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
        .onReceive(videoStore.$showRequestReview, perform: { showRequestReview in
            if showRequestReview {
                requestReview()
            }
        })
        .onReceive(imageStore.$showRequestReview, perform: { showRequestReview in
            if showRequestReview {
                requestReview()
            }
        })
        .onReceive(videoStore.$showAlertDonate, perform: { showAlertDonate in
            self.showAlertDonate = showAlertDonate
        })
        .onReceive(imageStore.$showAlertDonate, perform: { showAlertDonate in
            self.showAlertDonate = showAlertDonate
        })
        .alert(
            Counter.alertTitle,
            isPresented: $showAlertDonate,
            presenting: videoStore.grabCounter
        ) { grabCounter in
            Button("Donate 🍪") {
                videoStore.syncGrabCounter(grabCounter)
                openURL(Counter.donateURL)
            }
            Button("Cancel", role: .cancel) {
                videoStore.syncGrabCounter(grabCounter)
            }
        } message: { grabCounter in
            Text(Counter.alertMessage(count: grabCounter))
        }
        .frame(minWidth: Grid.minWidth, minHeight: Grid.minWHeight)
        .environmentObject(videoStore)
        .navigationTitle(coordinator.selectedTab.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VideoStore.shared)
    }
}
