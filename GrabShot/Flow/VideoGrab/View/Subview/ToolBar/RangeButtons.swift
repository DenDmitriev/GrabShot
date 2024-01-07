//
//  RangeButtons.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct RangeButtons: View {
    
    @Binding var playhead: Duration
    @Binding var currentRange: ClosedRange<Duration>
    
    var body: some View {
        HStack {
            Button(action: {
                currentRange = playhead...currentRange.upperBound
            }, label: {
                Image(systemName: "chevron.right.to.line")
            })
            .buttonStyle(.plain)
            .help(String(localized: "Mark In", comment: "Help"))
            
            Button(action: {
                currentRange = currentRange.lowerBound...playhead
            }, label: {
                Image(systemName: "chevron.left.to.line")
            })
            .buttonStyle(.plain)
            .help(String(localized: "Mark Out", comment: "Help"))
        }
        .font(.headline)
    }
}

#Preview {
    RangeButtons(playhead: .constant(.seconds(2.5)), currentRange: .constant(.init(uncheckedBounds: (lower: .seconds(0), upper: .seconds(5)))))
        .padding()
}
