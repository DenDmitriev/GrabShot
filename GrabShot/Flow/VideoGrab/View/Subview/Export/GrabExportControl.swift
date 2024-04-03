//
//  GrabExportPanel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

struct GrabExportControl: View {
    @ObservedObject var video: Video
    @EnvironmentObject var viewModel: VideoGrabViewModel
    @State private var isProgress: Bool = false
    
    var body: some View {
        VStack(spacing: AppGrid.pt16) {
            // Progress
            VStack(spacing: AppGrid.pt4) {
                HStack {
                    Text("\(Duration.seconds(video.duration) .formatted(.time(pattern: .hourMinuteSecond)))")
                    
                    Spacer()
                    
                    Text("\(video.progress.total) frames")
                    
                    if isProgress {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                            .padding(.horizontal)
                    }
                }
                .foregroundStyle(.secondary)
                
                GrabProgressPanel(video: video)
            }
            
            // Controls
            GrabExportControlView(video: video)
        }
        .onReceive(viewModel.$isProgress) { isProgress in
            self.isProgress = isProgress
        }
        .padding()
    }
}

#Preview {
    let videoStore = VideoStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    
    return GrabExportControl(video: .placeholder)
        .frame(width: 300)
        .environmentObject(VideoGrabViewModel.build(store: videoStore, score: scoreController))
}
