//
//  CoordinatorTab.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import SwiftUI

class CoordinatorTab: ObservableObject {
    
    @Published var selectedTab: Tab
    @ObservedObject var videoStore: VideoStore
    @ObservedObject var imageStore: ImageStore
    
    var grabView: GrabView
    var imageStripView: ImageSidebar
    
    init(videoStore: VideoStore, imageStore: ImageStore, scoreController: ScoreController) {
        self.videoStore = videoStore
        self.imageStore = imageStore
        let grabViewModel = GrabBuilder.build(store: videoStore, score: scoreController)
        self.grabView = GrabView(viewModel: grabViewModel, selection: grabViewModel.$videoStore.selectedVideos)
        self.imageStripView = ImageSidebar(viewModel: ImageSidebarModelBuilder.build(store: imageStore, score: scoreController))
        selectedTab = .grab
    }
}
