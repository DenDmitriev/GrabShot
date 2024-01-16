//
//  VideoDurationItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import SwiftUI

struct VideoDurationItemView: View {
    
    enum Style {
        case timecode, units
    }
    
    let video: Video
    var style: Style = .timecode
    @State private var isEnable = true
    @State private var duration: TimeInterval = .zero
    
    var body: some View {
        Text(text)
            .onReceive(video.$isEnable) { isEnable in
                self.isEnable = isEnable
            }
            .onReceive(video.$duration, perform: { duration in
                self.duration = duration
            })
            .foregroundColor(isEnable ? .primary : .secondary)
            .help("Duration video")
    }
    
    private var text: String {
        switch style {
        case .timecode:
            return DurationFormatter.string(duration)
        case .units:
            return DurationFormatter.stringWithUnits(duration) ?? "N/A"
        }
    }
}

struct VideoDurationItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDurationItemView(video: .placeholder)
    }
}
