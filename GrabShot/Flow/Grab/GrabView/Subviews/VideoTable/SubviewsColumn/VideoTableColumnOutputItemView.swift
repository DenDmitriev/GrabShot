//
//  VideoTableColumnOutputItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.08.2023.
//

import SwiftUI

struct VideoTableColumnOutputItemView: View {
    
    var video: Video
    @EnvironmentObject var viewModel: VideoTableModel
    @State private var hasExportDirectory = false
    @State private var showFileImporter = false
    
    var body: some View {
        Button {
            if hasExportDirectory {
                viewModel.outputDidTap(on: video)
            } else {
                showFileImporter = true
            }
        } label: {
            Label(hasExportDirectory
                  ? viewModel.getFormattedLinkLabel(url: video.exportDirectory)
                  : NSLocalizedString("Choose export directory", comment: "Button"),
                  systemImage: hasExportDirectory
                  ? "folder.fill"
                  : "questionmark.folder")
            .lineLimit(1)
            .multilineTextAlignment(.leading)
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.directory]
        ) { result in
            viewModel.hasExportDirectory(with: result, for: video)
        }
        .onReceive(video.$exportDirectory, perform: { url in
            if url != nil {
                self.hasExportDirectory = true
            }
        })
    }
}

struct VideoTableColumnOutputItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoTableColumnOutputItemView(video: Video(url: URL(string: "folder/video.mov")!))
    }
}
