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
            .font(.title)
            .help(String(localized: "Hour:Minutes:Seconds:Frame", comment: "Help"))
            .frame(width: AppGrid.pt128, alignment: .leading)
    }
}

#Preview {
    TimecodeView(playhead: .constant(.seconds(3.1)), frameRate: .constant(25))
        .padding()
}
