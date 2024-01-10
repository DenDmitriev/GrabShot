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
        GridItem(.flexible(minimum: 80, maximum: 120), alignment: .trailing),
        GridItem(.flexible(minimum: 160, maximum: 320), alignment: .leading)
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            Grid(alignment: .leadingFirstTextBaseline) {
                GridRow {
                    Text(String(localized: "File name", comment: "Title"))
                    HStack {
                        TextField(video.title, text: $video.grabName)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                GridRow {
                    Text(String(localized: "Location", comment: "Title"))
                    HStack {
                        TextField(
                            String(localized: "Export directory path"),
                            text: Binding(
                                get: { video.exportDirectory?.relativePath ?? "" },
                                set: { video.exportDirectory = URL(string: $0) }
                            ))
                        .disabled(true)
                        .textFieldStyle(.roundedBorder)
                        
                        Button(String(localized: "Browse", comment: "Title")) {
                            coordinator.contextVideoId = video.id
                            coordinator.showVideoExporter = true
                        }
                    }
                }
                
                GridRow {
                    Text(String(localized: "Period", comment: "Title"))
                    HStack(spacing: .zero) {
                        TextField("1...300", value: $period, format: .ranged(0...300))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: AppGrid.pt64)
                            .onChange(of: period) { period in
                                coordinator.videoStore.period = period
                            }
                        
                        Stepper("", value: $period, in: 1...300)
                            .padding(.leading, -AppGrid.pt8)
                    }
                }
                
                GridRow {
                    Text(String(localized: "Grab", comment: "Title"))
                    Picker("", selection: $video.range) {
                        Text(RangeType.full.label).tag(RangeType.full)
                        Text(RangeType.excerpt.label).tag(RangeType.excerpt)
                    }
                    .padding(.leading, -AppGrid.pt6)
                    .frame(width: AppGrid.pt100)
                }
            }
            .padding()
        }
        .frame(minWidth: AppGrid.pt256, idealWidth: AppGrid.pt300, maxWidth: AppGrid.pt400)
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
