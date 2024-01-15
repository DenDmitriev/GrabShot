//
//  ZoomSlider.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.01.2024.
//

import SwiftUI

struct ZoomSlider: View {
    @Binding var zoom: Double
    let range: ClosedRange<Double> = 1...9
    
    var body: some View {
        let step = (range.upperBound - range.lowerBound) / 15
        HStack {
            Button {
                zoom = max(zoom - step, range.lowerBound)
            } label: {
                Image(systemName: "minus")
            }
            .help(String(localized: "Zoom Out", comment: "Help"))
            
            CustomSlider(value: $zoom, in: range)
                .padding(.horizontal, AppGrid.pt8)
            
            Button {
                zoom = min(zoom + step, range.upperBound)
            } label: {
                Image(systemName: "plus")
            }
            .help(String(localized: "Zoom In", comment: "Help"))
        }
        .buttonStyle(.circle)
        .animation(.easeInOut, value: zoom)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var zoom: Double = 1
        
        var body: some View {
            ZoomSlider(zoom: $zoom)
                .padding()
        }
    }
    
    return PreviewWrapper()
}
