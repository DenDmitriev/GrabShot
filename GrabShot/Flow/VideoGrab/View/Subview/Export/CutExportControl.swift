//
//  CutExportPanel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 24.01.2024.
//

import SwiftUI

struct CutExportControl: View {
    @ObservedObject var video: Video
    @EnvironmentObject var viewModel: VideoGrabViewModel
    @State private var isProgress: Bool = false
    @State private var progress: Int = .zero
    @State private var total: Int = 1
    @State private var progressColors: [Color] = [.accentColor]
    
    var body: some View {
        VStack(spacing: AppGrid.pt16) {
            // Progress
            VStack(spacing: AppGrid.pt4) {
                HStack {
                    Text("\(video.rangeTimecode.duration.formatted(.time(pattern: .hourMinuteSecond)))")
                    
                    Spacer()
                    
                    if isProgress {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                            .padding(.horizontal)
                    }
                }
                .foregroundStyle(.secondary)
                
                ProgressColorView(progress: $progress, total: $total, colors: $progressColors)
                    .onReceive(video.progress.$total) { total in
                        self.total = total
                    }
                    .onReceive(video.progress.$current) { progress in
                        self.progress = progress
                    }
            }
            
            // Controls
            HStack {
                Spacer()
                
                Button {
                    viewModel.cut(video: video, from: video.rangeTimecode.lowerBound, to: video.rangeTimecode.upperBound)
                } label: {
                    Text("Cut")
                        .frame(minWidth: AppGrid.pt72)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isProgress)
                
                Button {
                    viewModel.cancel()
                } label: {
                    Text("Cancel")
                        .frame(minWidth: AppGrid.pt72)
                }
            }
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
    
    return CutExportControl(video: .placeholder)
        .frame(width: 300)
        .environmentObject(VideoGrabViewModel.build(store: videoStore, score: scoreController))
}
