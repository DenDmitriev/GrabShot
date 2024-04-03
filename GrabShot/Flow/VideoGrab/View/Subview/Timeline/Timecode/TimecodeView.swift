//
//  TimecodeView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct TimecodeView: View {
    @Binding var playhead: Duration
    @Binding var frameRate: Double
    
    var body: some View {
        Text(playhead.formatted(.timecode(frameRate: frameRate)))
            .foregroundStyle(.gray)
            .font(.title)
            .frame(width: AppGrid.pt128, alignment: .leading)
            .help(String(localized: "HH:MM:SS:FR", comment: "Help"))
    }
}

#Preview {
    TimecodeView(playhead: .constant(.seconds(3.1)), frameRate: .constant(25))
        .padding()
}
