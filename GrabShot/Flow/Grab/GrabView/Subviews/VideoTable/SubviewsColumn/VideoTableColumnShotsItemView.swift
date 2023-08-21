//
//  VideoTableColumnShotsItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoTableColumnShotsItemView: View {
    
    let video: Video
    @State private var total: Int = .zero
    @State private var isEnable = true
    
    var body: some View {
        Text(total.formatted(.number))
            .onReceive(video.$isEnable) { isEnable in
                self.isEnable = isEnable
            }
            .onReceive(video.progress.$total) { total in
                self.total = total
            }
            .foregroundColor(isEnable ? .primary : .gray)
    }
}

struct VideoTableColumnShotsItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoTableColumnShotsItemView(video: Video(url: URL(string: "MyVideo.mov")!))
    }
}
