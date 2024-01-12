//
//  VideoOutputItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.08.2023.
//

import SwiftUI

struct VideoOutputItemView: View {
    
    @ObservedObject var video: Video
    var includingText = true
    @EnvironmentObject var coordinator: GrabCoordinator
    @EnvironmentObject var viewModel: VideosModel
    @State private var hasExportDirectory = false
    
    var body: some View {
        Button {
            coordinator.showFileExporter(for: video.id)
        } label: {
            Label(hasExportDirectory
                  ? viewModel.getFormattedLinkLabel(url: video.exportDirectory)
                  : NSLocalizedString("Choose export directory", comment: "Button"),
                  systemImage: hasExportDirectory
                  ? (video.isEnable ? "folder.fill" : "folder")
                  : "questionmark.folder")
            .labelStyle(includingText: includingText)
            .ifTrue(video.exportDirectory == nil, apply: {
                AnyView($0
                    .foregroundColor(
                        video.exportDirectory == nil ? .red : .primary
                    )
                )}
            )
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .help("Choose export folder")
        }
        .buttonStyle(.link)
        .onReceive(video.$exportDirectory) { url in
            if url != nil {
                self.hasExportDirectory = true
            }
        }
    }
}

struct VideoOutputItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoOutputItemView(video: .placeholder)
            .environmentObject(VideosModel())
    }
}
