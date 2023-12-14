//
//  VideoRangeItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import SwiftUI

struct VideoRangeItemView: View {
    
    @State var video: Video
    var includingText = true
    @EnvironmentObject var videoStore: VideoStore
    @FocusedBinding(\.showRangePicker) private var showRangePicker
    @State private var rangeLabel: String = RangeType.full.label
    @State private var rangeImage: String = RangeType.full.image
    
    var body: some View {
        Button {
            videoStore.contextVideo = video.id
            showRangePicker = true
        } label: {
            Label(rangeLabel, systemImage: rangeImage)
                .labelStyle(includingText: includingText)
                .help("Select grabbing range")
        }
        .buttonStyle(.link)
        .onReceive(video.$range) { range in
            rangeLabel = range.label
            rangeImage = range.image
        }
    }
}

struct VideoRangeItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoRangeItemView(video: .placeholder)
            .environmentObject(VideoStore())
    }
}
