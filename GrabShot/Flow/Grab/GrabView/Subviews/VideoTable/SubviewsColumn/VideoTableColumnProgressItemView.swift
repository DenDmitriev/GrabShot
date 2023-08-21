//
//  VideoTableColumnProgressItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoTableColumnProgressItemView: View {
    
    let video: Video
    @State private var current: Int = .zero
    @State private var total: Int = .zero
    @State private var isEnable = true
    
    var body: some View {
        ProgressView(
            value: Double(current),
            total: Double(total)
        )
        .tint(isEnable ? .accentColor : .gray)
        .onReceive(video.$isEnable) { isEnable in
            self.isEnable = isEnable
        }
        .onReceive(video.progress.$current) { current in
            self.current = current
        }
        .onReceive(video.progress.$total) { total in
            self.total = total
        }
    }
}

struct VideoTableColumnProgressItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoTableColumnProgressItemView(video: Video(url: URL(string: "MyVideo.mov")!))
    }
}
