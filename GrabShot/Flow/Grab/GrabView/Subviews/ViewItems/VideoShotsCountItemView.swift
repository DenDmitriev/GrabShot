//
//  VideoShotsCountItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoShotsCountItemView: View {
    
    let video: Video
    var includingText = false
    @State private var total: Int = .zero
    @State private var isEnable = true
    
    var body: some View {
        HStack {
            Text(total.formatted(.number))
                .onReceive(video.$isEnable) { isEnable in
                    self.isEnable = isEnable
                }
                .onReceive(video.progress.$total) { total in
                    self.total = total
                }
                .foregroundColor(isEnable ? .primary : .gray)
                .help("Number of grabbing frames")
            
            if includingText {
                Text("frames")
            }
        }
    }
}

struct VideoShotsCountItemView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        VideoShotsCountItemView(video: Video(url: URL(string: "MyVideo.mov")!, store: store))
    }
}
