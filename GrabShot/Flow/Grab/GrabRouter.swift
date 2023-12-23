//
//  GrabRouter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 22.12.2023.
//

import SwiftUI

enum GrabRouter: NavigationRouter {
    case grab
    case rangePicker(videoId: Video.ID)
    case colorStrip(colors: [Color])
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .grab:
            "Video grab"
        case .rangePicker:
            "Range picker"
        case .colorStrip:
            "Color strip"
        }
    }
    
    func view(coordinator: GrabCoordinator) -> some View {
        switch self {
        case .grab:
            GrabView(viewModel: coordinator.buildViewModel(self) as! GrabModel, selection: coordinator.$videoStore.selectedVideos)
        case .rangePicker(let videoId):
            TimecodeRangeView(video: coordinator.videoStore[videoId])
        case .colorStrip(let colors):
            StripView(colors: colors)
        }
    }
}
