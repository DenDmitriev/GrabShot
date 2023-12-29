//
//  VideoGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI

struct VideoGrabView: View {
    
    @EnvironmentObject var coordinator: GrabCoordinator
    @Binding var video: Video
    @StateObject var viewModel: VideoGrabViewModel
    @AppStorage(DefaultsKeys.period) private var period: Int = 5
    @AppStorage(DefaultsKeys.stripViewMode) private var stripMode: StripMode = .liner
    @State var actionTitle: String = "Start"
    @State private var progress: Int = .zero
    @State private var total: Int = 1
    @State private var cursorVideo: Duration = .zero
    
    let columns: [GridItem] = [
        GridItem(.fixed(AppGrid.pt100), alignment: .trailing),
        GridItem(.flexible(minimum: AppGrid.pt100, maximum: AppGrid.pt1000), alignment: .leading)
    ]
    
    var body: some View {
        VStack {
            VideoPlayerView(video: video, cursor: $cursorVideo)
                .onReceive(viewModel.$currentTimecode) { timecode in
                    cursorVideo = timecode
                }
            
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
                .padding(.horizontal)
                .padding(.vertical, AppGrid.pt8)
                
                Divider()
                
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
                .padding(.horizontal)
                .padding(.vertical, AppGrid.pt8)
                
                Divider()
                
                VStack {
                    HStack {
                        ProgressColorView(progress: $progress, total: $total, colors: $video.colors, stripMode: stripMode)
                            .onReceive(video.progress.$total) { total in
                                self.total = total
                            }
                            .onReceive(video.progress.$current) { progress in
                                self.progress = progress
                            }
                        
                        Button {
                            if !video.colors.isEmpty {
                                coordinator.present(sheet: .colorStrip(colors: video.colors))
                            }
                        } label: {
                            Image(systemName: "barcode")
                        }
                        .disabled(video.colors.isEmpty)
                    }
                    
                    HStack {
                        HStack {
                            VideoDurationItemView(video: video, style: .units)
                            
                            Text("for")
                            
                            VideoShotsCountItemView(video: video)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            viewModel.grabbingRouter(for: video, period: period)
                        } label: {
                            Text(actionTitle)
                                .frame(minWidth: AppGrid.pt72)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            viewModel.cancel()
                        } label: {
                            Text("Cancel")
                                .frame(minWidth: AppGrid.pt72)
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.vertical, AppGrid.pt8)
                
            }
            .padding(.horizontal)
        }
        .onReceive(viewModel.$grabState) { state in
            switch state {
            case .ready, .calculating, .canceled, .complete:
                actionTitle = String(localized: "Start")
            case .grabbing:
                actionTitle = String(localized: "Pause")
            case .pause:
                actionTitle = String(localized: "Resume")
            }
        }
    }
}

#Preview {
    let videoStore = VideoStore()
    let score = ScoreController(caretaker: Caretaker())
    let viewModel: VideoGrabViewModel = .build(store: videoStore, score: score)
    let coordinator = GrabCoordinator(videoStore: videoStore, scoreController: score)
    
    return VideoGrabView(video: .constant(.placeholder), viewModel: viewModel)
        .environmentObject(viewModel)
        .environmentObject(coordinator)
}
