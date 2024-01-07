//
//  GrabPropertyView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.01.2024.
//

import SwiftUI

struct GrabPropertyView: View {
    @ObservedObject var video: Video
    @EnvironmentObject var coordinator: GrabCoordinator
    
    @AppStorage(DefaultsKeys.period) private var period: Int = 5
    
    private let columns: [GridItem] = [
        GridItem(.fixed(AppGrid.pt100), alignment: .trailing),
        GridItem(.flexible(minimum: AppGrid.pt100, maximum: AppGrid.pt1000), alignment: .leading)
    ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns) {
                Text("File name")
                HStack {
                    TextField(video.title, text: $video.grabName)
                        .textFieldStyle(.roundedBorder)
                }
                
                Text("Location")
                HStack {
                    TextField("Export directory path", text: Binding(
                        get: { video.exportDirectory?.relativePath ?? "" },
                        set: { video.exportDirectory = URL(string: $0) }
                    ))
                    .disabled(true)
                    .textFieldStyle(.roundedBorder)
                    
                    Button("Browse") {
                        coordinator.contextVideoId = video.id
                        coordinator.showVideoExporter = true
                    }
                }
            }
            
            HStack(spacing: AppGrid.pt16) {
                HStack(spacing: .zero) {
                    Text("Period")
                    TextField("1...300", value: $period, format: .ranged(0...300))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: AppGrid.pt64)
                        .padding(.leading, AppGrid.pt10)
                        .onChange(of: period) { period in
                            coordinator.videoStore.period = period
                        }
                    
                    Stepper("", value: $period, in: 1...300)
                        .padding(.leading, -AppGrid.pt8)
                }
                
                Picker("Grab", selection: $video.range) {
                    Text(RangeType.full.label).tag(RangeType.full)
                    Text(RangeType.excerpt.label).tag(RangeType.excerpt)
                }
                .frame(width: AppGrid.pt160)
            }
        }
    }
}

#Preview { 
    let videoStore = VideoStore()
    let score = ScoreController(caretaker: Caretaker())
//    let viewModel: VideoGrabViewModel = .build(store: videoStore, score: score)
    let coordinator = GrabCoordinator(videoStore: videoStore, scoreController: score)
    
    return GrabPropertyView(video: .placeholder)
        .environmentObject(coordinator)
}
