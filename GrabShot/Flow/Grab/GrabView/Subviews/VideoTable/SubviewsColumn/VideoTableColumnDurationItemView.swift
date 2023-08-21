//
//  VideoTableColumnDurationItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoTableColumnDurationItemView: View {
    
    let video: Video
    @State private var isEnable = true
    @State private var duration: TimeInterval = .zero
    
    var body: some View {
        Text(DurationFormatter.string(duration))
            .onReceive(video.$isEnable) { isEnable in
                self.isEnable = isEnable
            }
            .onReceive(video.$duration, perform: { duration in
                self.duration = duration
            })
            .foregroundColor(isEnable ? .primary : .gray)
    }
}

struct VideoTableColumnDurationItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoTableColumnDurationItemView(video: Video(url: URL(string: "MyVideo.mov")!))
    }
}
