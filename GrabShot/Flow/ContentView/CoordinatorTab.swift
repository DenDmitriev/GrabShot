//
//  CoordinatorTab.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import SwiftUI

class CoordinatorTab: ObservableObject {
    
    @Published var selectedTab: Tab
//    @SceneStorage("activeTab") var selectedTab: Tab = .grab
    
    var grabView: GrabView
    var imageStripView: ImageSidebar
    
    init(videoStore: VideoStore) {
        self.grabView = GrabView(viewModel: GrabModel(store: videoStore))
        self.imageStripView = ImageSidebar(viewModel: ImageSidebarModel())
        selectedTab = .grab
    }
}
