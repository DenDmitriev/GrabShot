//
//  VideoThumb.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import SwiftUI

struct VideoThumb: View {
    static let aspect: CGFloat = 16 / 9
    var video: Video
    @State var imageURL: URL?
    @State private var size: CGSize = .zero

    var body: some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay {
                    if video.progress.current > 0,
                       video.progress.current != video.progress.total {
                        VideoGrabProgressItemView()
                            .environmentObject(video.progress)
                            .frame(width: AppGrid.pt48, height: AppGrid.pt48)
                    }
                }
        } placeholder: {
            ZStack {
                Color.clear
                
                Image(systemName: "film")
                    .symbolVariant(.fill)
                    .font(.system(size: AppGrid.pt36))
                    .foregroundColor(.gray)
            }
            .frame(height: size.width / Self.aspect)
            .background(.quinary)
        }
        .background(content: {
            Color.clear
                .readSize(onChange: { size in
                    self.size = size
                })
        })
        .onReceive(video.$coverURL) { coverURL in
            self.imageURL = coverURL
        }
    }
}

#Preview {
    let video: Video = {
        let video: Video = .placeholder
        video.images = [Bundle.main.url(forResource: "Placeholder", withExtension: "jpg")!]
        return video
    }()
    return VStack {
        VideoThumb(video: .placeholder)
            
        VideoThumb(video: video)
    }
    .frame(width: 300)
    .padding()
}
