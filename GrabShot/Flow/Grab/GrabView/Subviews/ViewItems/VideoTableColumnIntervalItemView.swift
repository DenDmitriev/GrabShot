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
    @Binding var showRangeGlobal: Bool
    @State var showRange: Bool = false
    @State private var rangeLabel: String = RangeType.full.label
    @State private var rangeImage: String = RangeType.full.image
    
    var body: some View {
        Button {
            showRange.toggle()
        } label: {
            Label(rangeLabel, systemImage: rangeImage)
                .labelStyle(includingText: includingText)
                .help("Select grabbing range")
        }
        .onChange(of: showRange, perform: { showRange in
            showRangeGlobal = showRange
        })
        .onChange(of: showRangeGlobal, perform: { showRangeGlobal in
            showRange = showRangeGlobal
        })
        .buttonStyle(.link)
        .sheet(isPresented: $showRange) {
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
        VideoRangeItemView(video: .placeholder, showRangeGlobal: .constant(false))
    }
}
