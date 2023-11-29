//
//  VideoProgressItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoProgressItemView: View {
    
    let video: Video
    @State private var current: Int = .zero
    @State private var total: Int = .zero
    @State private var isEnable = true
    @State private var isCompleted = false
    
    var body: some View {
        Group {
            if isCompleted {
                Label("Done", systemImage: "checkmark")
                    .foregroundColor(.green)
            } else {
                ProgressView(
                    value: Double(current),
                    total: Double(total)
                )
                .tint(isEnable ? .accentColor : .gray)
            }
        }
        .onReceive(video.$isEnable) { isEnable in
            self.isEnable = isEnable
        }
        .onReceive(video.progress.$current) { current in
            self.current = current
            if current == total,
               total != .zero {
                isCompleted = true
            } else if isCompleted {
                isCompleted = false
            }
        }
        .onReceive(video.progress.$total) { total in
            self.total = total
        }
    }
}

struct VideoProgressItemView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        VideoProgressItemView(video: Video(url: URL(string: "MyVideo.mov")!, store: store))
    }
}
