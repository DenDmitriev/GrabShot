//
//  StripView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2022.
//

import SwiftUI

struct StripView: View {
    
    @ObservedObject var viewModel: StripModel
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                HStack(spacing: 0) {
                    ForEach(viewModel.video?.colors ?? [Color.clear], id: \.self) { color in
                        Rectangle()
                            .fill(color)
                    }
                    .animation(.easeInOut, value: viewModel.video?.colors)
                }
            }
        }
    }
}

struct StripView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let videoPreview: Video = {
            let video = Video(url: URL(string: "ABC")!)
            video.colors = [
                Color(red: 0.1, green: 0.9, blue: 0.5),
                Color(red: 0.6, green: 0.1, blue: 0.4),
                Color(red: 0.2, green: 0.5, blue: 0.7),
                Color(red: 0.8, green: 0.5, blue: 0.9)
            ]
            return video
        }()
        
        StripView(viewModel: StripModel(video: videoPreview))
            .previewLayout(.fixed(width: 256, height: 256))
    }
}