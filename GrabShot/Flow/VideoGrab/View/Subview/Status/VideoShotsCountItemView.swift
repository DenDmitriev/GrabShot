//
//  VideoShotsCountItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoShotsCountItemView: View {
    
    let video: Video
    @State private var total: Int = .zero
    @State private var isEnable = true
    
    var body: some View {
        HStack {
            Text(String(localized: "\(total) frames", comment: "Title"))
                .onReceive(video.$isEnable) { isEnable in
                    self.isEnable = isEnable
                }
                .onReceive(video.progress.$total) { total in
                    self.total = total
                }
                .help("Number of grabbing frames")
        }
        .foregroundColor(isEnable ? .primary : .secondary)
    }
}

#Preview {
    let video: Video = {
        let video = Video.placeholder
        video.progress.total = 1
        return video
    }()
    
    return VideoShotsCountItemView(video: video)
        .padding()
}
