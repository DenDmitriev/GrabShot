//
//  GrabControlView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.01.2024.
//

import SwiftUI

struct GrabExportControlView: View {
    
    @ObservedObject var video: Video
    @StateObject var viewModel: VideoGrabViewModel
    @AppStorage(DefaultsKeys.period) private var period: Double = 5
    @State private var actionTitle: String = "Start"
    
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.grabbingRouter(for: video, period: period)
            } label: {
                Text(actionTitle)
                    .frame(minWidth: AppGrid.pt72)
                    .onReceive(viewModel.$grabState) { state in
                        switch state {
                        case .ready, .calculating, .canceled, .complete:
                            actionTitle = String(localized: "Grab Frames")
                        case .grabbing:
                            actionTitle = String(localized: "Pause")
                        case .pause:
                            actionTitle = String(localized: "Resume")
                        }
                    }
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                viewModel.cancel()
            } label: {
                Text("Cancel")
                    .frame(minWidth: AppGrid.pt72)
            }
        }
    }
}

#Preview {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let score = ScoreController(caretaker: Caretaker())
    
    let viewModel: VideoGrabViewModel = .build(store: videoStore, score: score)
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: score)
    
    return GrabExportControlView(video: .placeholder, viewModel: viewModel)
        .environmentObject(coordinator)
}
