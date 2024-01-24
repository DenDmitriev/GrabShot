//
//  CutExportPanel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 24.01.2024.
//

import SwiftUI

struct CutExportPanel: View {
    @ObservedObject var video: Video
    @EnvironmentObject var viewModel: VideoGrabViewModel
    @State private var isProgress: Bool = false
    @State private var progress: Int = .zero
    @State private var total: Int = 1
    @State private var progressColors: [Color] = [.accentColor]
    
    var body: some View {
        VStack(spacing: AppGrid.pt16) {
            // Progress
            ProgressColorView(progress: $progress, total: $total, colors: $progressColors)
                .frame(minHeight: AppGrid.pt20)
                .onReceive(video.progress.$total) { total in
                    self.total = total
                }
                .onReceive(video.progress.$current) { progress in
                    self.progress = progress
                }
            
            // Controls
            HStack {
                Text("Длительность")
                
                Text(DurationFormatter.stringWithUnits(video.rangeTimecode.timeInterval) ?? "N/A")
                
                Spacer()
                
                if isProgress {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                        .padding(.horizontal)
                }
                
                Button {
                    if video.rangeTimecode != video.timelineRange {
                        viewModel.cut(video: video, from: video.rangeTimecode.lowerBound, to: video.rangeTimecode.upperBound)
                    }
                } label: {
                    Text("Trim")
                        .frame(minWidth: AppGrid.pt72)
                }
                .disabled(video.rangeTimecode == video.timelineRange)
                
                Button {
                    viewModel.cancel()
                } label: {
                    Text("Cancel")
                        .frame(minWidth: AppGrid.pt72)
                }
            }
            .padding(.bottom)
        }
        .onReceive(viewModel.$isProgress) { isProgress in
            self.isProgress = isProgress
        }
        .padding(.vertical, AppGrid.pt8)
        .padding(.horizontal)
        .background(.toolbar)
    }
}

#Preview {
    let videoStore = VideoStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    
    return CutExportPanel(video: .placeholder)
        .environmentObject(VideoGrabViewModel.build(store: videoStore, score: scoreController))
}
