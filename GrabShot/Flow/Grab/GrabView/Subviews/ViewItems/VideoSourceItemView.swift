//
//  VideoSourceItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoSourceItemView: View {
    
    var video: Video
    var includingText = true
    @EnvironmentObject var viewModel: VideosModel
    
    var body: some View {
        Button {
            viewModel.openFolder(by: video.url)
        } label: {
            Label(
                viewModel.getFormattedLinkLabel(url: video.url),
                systemImage: video.isEnable ? "film.fill" : "film"
            )
            .labelStyle(includingText: includingText)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .help("Show source file in Finder")
        }
        .buttonStyle(.link)
    }
    
    @ViewBuilder
    func labelStyle(includingText: Bool) -> some View {
        if includingText {
            self.labelStyle(.titleAndIcon)
        } else {
            self.labelStyle(.iconOnly)
        }
    }
}

struct VideoSourceItemView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        VideoSourceItemView(video: Video(url: URL(string: "MyVideo.mov")!, store: store))
            .environmentObject(VideosModel(grabModel: GrabModel(store: store)))
    }
}


