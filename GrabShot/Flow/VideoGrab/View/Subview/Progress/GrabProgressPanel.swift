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
        ProgressColorView(progress: $progress, total: $total, colors: $video.grabColors, stripMode: stripMode)
            .onReceive(video.progress.$total) { total in
                self.total = total
            }
            .onReceive(video.progress.$current) { progress in
                self.progress = progress
            }
            .onTapGesture {
                if !video.grabColors.isEmpty {
                    coordinator.present(sheet: .colorStrip(colors: video.grabColors))
                }
            }
            .help("Show Color Barcode")
    }
}

#Preview {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let score = ScoreController(caretaker: Caretaker())
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: score)
    
    return GrabProgressPanel(video: .placeholder)
        .environmentObject(coordinator)
}
