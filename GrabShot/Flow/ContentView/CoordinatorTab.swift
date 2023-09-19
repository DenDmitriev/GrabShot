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
    
    init() {
        self.grabView = GrabView(viewModel: GrabModel())
        self.imageStripView = ImageSidebar(viewModel: ImageSidebarModel())
        selectedTab = .grab
    }
}
