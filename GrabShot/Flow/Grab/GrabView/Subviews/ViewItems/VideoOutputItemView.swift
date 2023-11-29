//
//  VideoOutputItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.08.2023.
//

import SwiftUI

struct VideoOutputItemView: View {
    
    var video: Video
    var includingText = true
    @EnvironmentObject var viewModel: VideosModel
    @State private var hasExportDirectory = false
    @State private var showFileExporter = false
    
    var body: some View {
        Button {
            showFileExporter = true
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
        .fileExporter(
            isPresented: $showFileExporter,
            document: ExportDirectory(title: video.title),
            contentType: .directory,
            defaultFilename: video.title
        ) { result in
            viewModel.hasExportDirectory(with: result, for: video)
        }
        .onReceive(video.$exportDirectory) { url in
            if url != nil {
                self.hasExportDirectory = true
            }
        }
    }
}

struct VideoOutputItemView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        VideoOutputItemView(video: .placeholder)
            .environmentObject(VideosModel(grabModel: GrabModel(store: store)))
    }
}
