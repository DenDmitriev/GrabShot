//
//  ExportPropertyView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

struct ExportPropertyView: View {
    
    @ObservedObject var video: Video
    @EnvironmentObject var coordinator: GrabCoordinator
    
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 80, maximum: 120), alignment: .trailing),
        GridItem(.flexible(minimum: 160, maximum: 320), alignment: .leading)
    ]
    
    var body: some View {
        Grid(alignment: .leadingFirstTextBaseline) {
            GridRow {
                Text(String(localized: "File name", comment: "Title"))
                HStack {
                    TextField(video.title, text: $video.grabName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: AppGrid.pt256)
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
                    .frame(maxWidth: AppGrid.pt256)
                    .textFieldStyle(.roundedBorder)
                    .overlay {
                        if coordinator.showRequirements {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.red)
                                .hidden(video.exportDirectory != nil)
                        }
                    }
                    .onChange(of: video.exportDirectory) { _ in
                        coordinator.checkRequirements(for: video)
                    }
                    
                    Button(String(localized: "Browse", comment: "Title")) {
                        coordinator.contextVideoId = video.id
                        coordinator.showVideoExporter = true
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    let videoStore = VideoStore()
    let imageStore = ImageStore()
    let score = ScoreController(caretaker: Caretaker())
    let coordinator = GrabCoordinator(videoStore: videoStore, imageStore: imageStore, scoreController: score)
    
    return ExportPropertyView(video: .placeholder)
        .environmentObject(coordinator)
}
