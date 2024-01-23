//
//  GrabExportPanel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

struct GrabExportPanel: View {
    @ObservedObject var video: Video
    @EnvironmentObject var viewModel: VideoGrabViewModel
    
    var body: some View {
        VStack(spacing: AppGrid.pt16) {
            // Progress
            GrabProgressPanel(video: video)
            
            // Controls
            GrabExportControlView(video: video, viewModel: viewModel)
                .padding(.bottom)
        }
        .padding(.vertical, AppGrid.pt8)
        .padding(.horizontal)
    }
}

#Preview {
    let videoStore = VideoStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    
    return GrabExportPanel(video: .placeholder)
        .environmentObject(VideoGrabViewModel.build(store: videoStore, score: scoreController))
}
