//
//  TabCoordinatorView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI
import StoreKit

struct TabCoordinatorView: View {
    
    @StateObject var coordinator: TabCoordinator
    @Environment(\.openWindow) var openWindow
    @Environment(\.openURL) var openURL
    @Environment(\.requestReview) var requestReview
    @AppStorage(DefaultsKeys.showOverview) var showOverview: Bool = true
    @EnvironmentObject var scoreController: ScoreController
    @EnvironmentObject var imageStore: ImageStore
    @EnvironmentObject var videoStore: VideoStore
    @State private var showAlertDonate = false
    
    var body: some View {
        Group {
            switch coordinator.route {
            case .grab:
                coordinator.build(.grab)
            case .imageStrip:
                coordinator.build(.imageStrip)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Picker("Picker", selection: $coordinator.route) {
                    Image(systemName: coordinator.route == TabRouter.grab ? TabRouter.grab.imageForSelected : TabRouter.grab.image)
                        .help("Video grab")
                        .tag(TabRouter.grab)
                    
                    Image(systemName: coordinator.route == TabRouter.imageStrip ? TabRouter.imageStrip.imageForSelected : TabRouter.imageStrip.image)
                        .help("Image colors")
                        .tag(TabRouter.imageStrip)
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
                    openWindow(id: WindowId.overview.id)
                } label: {
                    Label("Overview", systemImage: "questionmark.circle")
                }
                .disabled(showOverview)
            }
        }
        .navigationTitle(coordinator.route.title)
        .environmentObject(coordinator)
        .onChange(of: videoStore.videos) { _ in
            if coordinator.route != .grab {
                coordinator.route = .grab
            }
        }
        .onChange(of: imageStore.imageStrips) { newValue in
            if coordinator.route != .imageStrip {
                coordinator.route = .imageStrip
            }
        }
        .alert(isPresented: $coordinator.hasError, error: coordinator.error) { _ in
            Button("OK", role: .cancel) {
                print("alert dismiss")
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
        .onReceive(coordinator.videoStore.$showAlert) { showAlert in
            if showAlert, let error = coordinator.videoStore.error {
                coordinator.presentAlert(error: error)
                coordinator.videoStore.showAlert = false
            }
        }
        .onReceive(coordinator.imageStore.$showAlert) { showAlert in
            if showAlert, let error = coordinator.imageStore.error {
                coordinator.presentAlert(error: error)
                coordinator.imageStore.showAlert = false
            }
        }
        .onReceive(scoreController.$showRequestReview, perform: { showRequestReview in
            if showRequestReview {
                requestReview()
                scoreController.isEnable = false
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
                scoreController.isEnable = false
            }
            Button("Cancel", role: .cancel) {
                scoreController.isEnable = false
            }
        } message: { grabCounter in
            Text(ScoreController.alertMessage(count: grabCounter))
        }
        .frame(minWidth: AppGrid.minWidth, minHeight: AppGrid.minWHeight)
    }
}

#Preview("TabCoordinatorView") {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    
    return TabCoordinatorView(coordinator: TabCoordinator(tab: .grab, videoStore: videoStore, imageStore: imageStore, scoreController: scoreController))
        .environmentObject(scoreController)
        .environmentObject(videoStore)
        .environmentObject(imageStore)
}
