//
//  ContentView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @EnvironmentObject var imageStore: ImageStore
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var coordinator: CoordinatorTab
    @EnvironmentObject var scoreController: ScoreController
    
    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow
    @Environment(\.requestReview) var requestReview
    
    @AppStorage(DefaultsKeys.showOverview)
    var showOverview: Bool = true
    
    @State private var error: GrabShotError? = nil
    @State private var showAlert = false
    @State private var showAlertDonate = false
    
    var body: some View {
        Group {
            switch coordinator.selectedTab {
            case .grab:
                coordinator.grabView
                    .tag(Tab.grab)
            case .imageStrip:
                coordinator.imageStripView
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
        .onReceive(scoreController.$showRequestReview, perform: { showRequestReview in
            if showRequestReview {
                requestReview()
            }
        })
        .onReceive(scoreController.$showAlertDonate, perform: { showAlertDonate in
            self.showAlertDonate = showAlertDonate
        })
        .alert(
            ScoreController.alertTitle,
            isPresented: $showAlertDonate,
            presenting: scoreController.grabCount
        ) { grabCounter in
            Button("Donate 🍪") {
                openURL(ScoreController.donateURL)
            }
            Button("Cancel", role: .cancel) {}
        } message: { grabCounter in
            Text(ScoreController.alertMessage(count: grabCounter))
        }
        .frame(minWidth: Grid.minWidth, minHeight: Grid.minWHeight)
        .navigationTitle(coordinator.selectedTab.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let videoStore = VideoStore()
        let imageStore = ImageStore()
        let scoreController = ScoreController(caretaker: Caretaker())
        let coordinator = CoordinatorTab(videoStore: videoStore, imageStore: imageStore, scoreController: scoreController)
        
        ContentView()
            .environmentObject(scoreController)
            .environmentObject(coordinator)
            .environmentObject(videoStore)
            .environmentObject(imageStore)
    }
}
