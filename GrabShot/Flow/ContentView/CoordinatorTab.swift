//
//  CoordinatorTab.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import SwiftUI

class CoordinatorTab: ObservableObject {
    
    @Published var selectedTab: Tab
    
    var grabView: GrabView
    var imageStripView: ImageSidebar
    
    init(videoStore: VideoStore, imageStore: ImageStore, scoreController: ScoreController) {
        self.grabView = GrabView(viewModel: GrabBuilder.build(store: videoStore, score: scoreController))
        self.imageStripView = ImageSidebar(viewModel: ImageSidebarModelBuilder.build(store: imageStore, score: scoreController))
        selectedTab = .grab
    }
}
