//
//  VideoGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI

struct VideoGrabView: View {
    
    @State var video: Video
    @StateObject var viewModel: VideosModel
    @State var period: Int = 5
    
    let columns: [GridItem] = [
        GridItem(.fixed(AppGrid.pt100), alignment: .trailing),
        GridItem(.flexible(minimum: AppGrid.pt100, maximum: AppGrid.pt1000), alignment: .leading)
    ]
    
    var body: some View {
        VStack {
            VideoPlayerView(video: video)
            
            LazyVGrid(columns: columns) {
                Text("File")
                Text(video.url.lastPathComponent)
                
                Text("Location")
                HStack {
                    TextField("Export directory path", text: Binding(
                        get: { video.exportDirectory?.absoluteString ?? "" },
                        set: { video.exportDirectory = URL(string: $0) }
                    ))
                    Button("Browse") { }
                }
                
                Text("Period")
                HStack {
                    Stepper(value: $period, in: 1...300) {
                        TextField("1...300", value: $period, format: .ranged(0...300))
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: AppGrid.pt80)
                    }
                    Text("seconds")
                }
            }
            .padding()
            
            HStack {
                Button("Cancel") { }
                Button("Start") { }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview {
    let viewModel = VideosModel()
    
    return VideoGrabView(video: .placeholder, viewModel: viewModel)
        .environmentObject(viewModel)
}
