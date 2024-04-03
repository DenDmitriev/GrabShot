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
    
    @AppStorage(DefaultsKeys.period) private var period: Double = 5
    
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 80, maximum: 120), alignment: .trailing),
        GridItem(.flexible(minimum: 160, maximum: 320), alignment: .leading)
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            Grid(alignment: .leadingFirstTextBaseline) {
                GridRow {
                    let range: ClosedRange<Double> = 1...300
                    Text(String(localized: "Period", comment: "Title"))
                    HStack(spacing: .zero) {
                        CustomSlider(value: $period, in: range)
                            .padding(.trailing)
                        TextField("1...300", value: $period, format: .ranged(range))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: AppGrid.pt64)
                            .onChange(of: period) { period in
                                coordinator.videoStore.period = period
                            }
                        
                        Stepper("", value: $period, in: range)
                            .padding(.leading, -AppGrid.pt8)
                        
                        Text("seconds")
                            .padding(.leading, AppGrid.pt4)
                    }
                }
                
                GridRow {
                    Text(String(localized: "Range", comment: "Title"))
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
    let imageStore = ImageStore()
    let score = ScoreController(caretaker: Caretaker())
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: score)
    
    return GrabPropertyView(video: .placeholder)
        .environmentObject(coordinator)
}
