//
//  VideoTableColumnTitleItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoTableColumnTitleItemView: View {
    
    var video: Video
    @EnvironmentObject var viewModel: VideoTableModel
    
    var body: some View {
        Button {
            viewModel.openFolder(by: video.url)
        } label: {
            Label(video.title,
                  systemImage: video.isEnable ? "film.fill" : "film"
            )
            .lineLimit(1)
            .multilineTextAlignment(.leading)
        }
        .buttonStyle(.link)
    }
}

struct VideoTableColumnTitleItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoTableColumnTitleItemView(video: Video(url: URL(string: "MyVideo.mov")!))
    }
}
