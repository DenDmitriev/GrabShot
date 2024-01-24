//
//  GrabStatusView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.01.2024.
//

import SwiftUI

struct GrabStatusView: View {
    @ObservedObject var video: Video
    
    var body: some View {
        HStack {
            Text("Длительность")
            
            VideoDurationItemView(video: video, style: .units)
            
            Text("for")
            
            VideoShotsCountItemView(video: video)
        }
    }
}

#Preview {
    GrabStatusView(video: .placeholder)
}
