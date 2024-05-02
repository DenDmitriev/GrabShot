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
    @EnvironmentObject var videoViewModel: VideoGrabSidebarModel
    @EnvironmentObject var imageViewModel: ImageSidebarModel
    
    @State private var showAlertDonate = false
    
    @AppStorage(DefaultsKeys.activeTab)
    private var activeTab: TabRouter = .imageStrip
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            switch coordinator.route {
            case .videoGrab:
                if let grabCoordinator = coordinator.getCoordinator(tab: .videoGrab) as? GrabCoordinator {
                    VideoStoreView()
                        .environmentObject(grabCoordinator)
                        .onAppear {
                            videoViewModel.coordinator = grabCoordinator
                        }
                }
                
            case .imageStrip:
                if let stripCoordinator = coordinator.getCoordinator(tab: .imageStrip) as? ImageStripCoordinator {
                    ImageStoreView()
                        .environmentObject(stripCoordinator)
                        .onAppear {
                            imageViewModel.coordinator = stripCoordinator
                        }
                }
            }
        } detail: {
            switch coordinator.route {
            case .videoGrab:
                coordinator.build(.videoGrab)
            case .imageStrip:
                coordinator.build(.imageStrip)
            }
        }
        .onAppear {
            coordinator.route = activeTab
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Picker("Picker", selection: $coordinator.route) {
                    Image(systemName: coordinator.route == TabRouter.videoGrab ? TabRouter.videoGrab.imageForSelected : TabRouter.videoGrab.image)
                        .help("Video grab")
                        .tag(TabRouter.videoGrab)
                    
                    Image(systemName: coordinator.route == TabRouter.imageStrip ? TabRouter.imageStrip.imageForSelected : TabRouter.imageStrip.image)
                        .help("Image colors")
                        .tag(TabRouter.imageStrip)
                }
                .pickerStyle(.segmented)
                .disabled(videoStore.isProgress)
            }
            
            ToolbarItem {
                Spacer()
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                if #available(macOS 14.0, *) {
                    SettingsLink {
                        Label("Settings", systemImage: "gear")
                    }
                    .help("Open settings")
                } else {
                    Button {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    .help("Open settings")
                }
                
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
        .onChange(of: coordinator.route) { activeTab in
            UserDefaultsService.default.activeTab = activeTab
        }
        .onChange(of: videoStore.videos) { _ in
            if coordinator.route != .videoGrab {
                coordinator.route = .videoGrab
                
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
            Text(error.failureReason ?? "failureReason")
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
        .frame(minWidth: AppGrid.minWidth, minHeight: AppGrid.minHeight)
        .onChange(of: UserDefaultsService.default.showPlayback) { showPlayback in
            updateWindowSize(expand: showPlayback, AppGrid.minWidthPlayback, location: .width)
        }
        .onChange(of: UserDefaultsService.default.showTimeline) { showTimeline in
            updateWindowSize(expand: showTimeline, AppGrid.minHeightTimeline, location: .height)
        }
        .onChange(of: columnVisibility) { columnVisibility in
            switch columnVisibility {
            case .detailOnly:
                updateWindowSize(expand: false, AppGrid.minWidthSidebar, location: .width)
            case .all:
                updateWindowSize(expand: true, AppGrid.minWidthSidebar, location: .width)
            default:
                break
            }
        }
    }
    
    private enum WindowUpdate {
        case height, width
    }
    
    private func updateWindowSize(expand: Bool, _ value: CGFloat, location: WindowUpdate) {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                var size = window.frame.size
                switch location {
                case .height:
                    size.height = expand ? size.height + value : size.height - value
                case .width:
                    size.width = expand ? size.width + value : size.width - value
                }
                window.setFrame(NSRect(origin: window.frame.origin, size: size), display: true, animate: true)
            }
        }
    }
}

#Preview("TabCoordinatorView") {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    
    return TabCoordinatorView(coordinator: TabCoordinator(tab: .videoGrab, videoStore: videoStore, imageStore: imageStore, scoreController: scoreController))
        .environmentObject(scoreController)
        .environmentObject(videoStore)
        .environmentObject(imageStore)
}
