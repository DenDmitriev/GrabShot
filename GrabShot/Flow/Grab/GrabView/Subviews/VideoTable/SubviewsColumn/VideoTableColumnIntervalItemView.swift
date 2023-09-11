//
//  VideoRangeItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import SwiftUI

struct VideoRangeItemView: View {
    
    let video: Video
    var includingText = true
    @State var isShowIntervalSettings = false
    @State private var rangeLabel: String = RangeType.full.label
    @State private var rangeImage: String = RangeType.full.image
    
    var body: some View {
        Button {
            isShowIntervalSettings.toggle()
        } label: {
            Label(rangeLabel, systemImage: rangeImage)
                .labelStyle(includingText: includingText)
                .help("Select grabbing range")
        }
        .buttonStyle(.link)
        .sheet(isPresented: $isShowIntervalSettings) {
            TimecodeRangeView(
                fromTimecode: video.fromTimecode,
                toTimecode: video.toTimecode,
                selectedRange: Binding<RangeType>(
                    get: { video.range },
                    set: { range in video.range = range }
                )
            )
        }
        .onReceive(video.$range) { range in
            rangeLabel = range.label
            rangeImage = range.image
        }
    }
}

struct VideoRangeItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoRangeItemView(video: Video(url: URL(string: "MyVideo.mov")!))
    }
}
