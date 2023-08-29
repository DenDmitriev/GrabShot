//
//  CoordinatorTab.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import Foundation

class CoordinatorTab: ObservableObject {
    
    @Published var selectedTab: Tab
    
    var dropView: DropView
    var grabView: GrabView
    var imageStripView: ImageSidebar
    
    init() {
        self.dropView = DropView()
        self.grabView = GrabView(viewModel: GrabModel())
        self.imageStripView = ImageSidebar(viewModel: ImageSidebarModel())
        selectedTab = .drop
    }
}
