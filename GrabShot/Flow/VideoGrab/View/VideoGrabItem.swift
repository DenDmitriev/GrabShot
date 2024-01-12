//
//  VideoGrabItem.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import SwiftUI
import AppKit

struct VideoGrabItem: View {
    @ObservedObject var video: Video
    @ObservedObject var viewModel: VideoGrabSidebarModel
    @Binding var selection: Set<Video.ID>
    
    var body: some View {
        VStack {
            VideoThumb(video: video)
                .onHover(perform: { hovering in
//                    updateCover()
                })
                .onAppear {
                    updateCover()
                }
            
            Text(video.title)
        }
    }
    
    var isSelected: Bool {
        selection.contains(video.id)
    }
    
    private func updateCover() {
        viewModel.updateCover(video: video)
    }
}

#Preview {
    let video: Video = .placeholder
    let videoStore = VideoStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let selection: Set<Video.ID> = [video.id]
    let viewModel = VideoGrabSidebarModel.build(store: videoStore, score: scoreController)
    
    return VideoGrabItem(video: video, viewModel: viewModel, selection: .constant(selection))
        .frame(width: AppGrid.pt300, height: AppGrid.pt300)
        .padding()
}
