//
//  GrabProgressPanel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.01.2024.
//

import SwiftUI

struct GrabProgressPanel: View {
    @EnvironmentObject var coordinator: GrabCoordinator
    @ObservedObject var video: Video
    @State private var progress: Int = .zero
    @State private var total: Int = 1
    @AppStorage(DefaultsKeys.stripViewMode) private var stripMode: StripMode = .liner
    
    var body: some View {
        HStack {
            ProgressColorView(progress: $progress, total: $total, colors: $video.grabColors, stripMode: stripMode)
                .onReceive(video.progress.$total) { total in
                    self.total = total
                }
                .onReceive(video.progress.$current) { progress in
                    self.progress = progress
                }
            
            Button {
                if !video.grabColors.isEmpty {
                    coordinator.present(sheet: .colorStrip(colors: video.grabColors))
                }
            } label: {
                Image(systemName: "barcode")
            }
            .disabled(video.grabColors.isEmpty)
        }
    }
}

#Preview {
    let videoStore = VideoStore()
    let score = ScoreController(caretaker: Caretaker())
    let coordinator = GrabCoordinator(videoStore: videoStore, scoreController: score)
    
    return GrabProgressPanel(video: .placeholder)
        .environmentObject(coordinator)
}
