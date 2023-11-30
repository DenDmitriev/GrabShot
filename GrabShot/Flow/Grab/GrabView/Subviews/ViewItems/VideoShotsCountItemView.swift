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
                .help("Number of grabbing frames")
            
            if includingText {
                Text("frames")
            }
        }
        .foregroundColor(isEnable ? .primary : .secondary)
    }
}

struct VideoShotsCountItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoShotsCountItemView(video: .placeholder)
    }
}
