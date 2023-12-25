//
//  GalleryImage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.12.2023.
//

import SwiftUI

struct GalleryImage: View {
    static let aspect: CGFloat = 16 / 9
    var video: Video
    @State var imageURL: URL?
    var size: CGFloat

    var body: some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size / Self.aspect)
                .cornerRadius(AppGrid.pt8)
                .background(background)
                .overlay {
                    if video.progress.current > 0,
                       video.progress.current != video.progress.total {
                        VideoGrabProgressItemView()
                            .environmentObject(video.progress)
                            .frame(width: AppGrid.pt48, height: AppGrid.pt48)
                    }
                }
        } placeholder: {
            Image(systemName: "film")
                .symbolVariant(.fill)
                .font(.system(size: 40))
                .foregroundColor(.gray)
                .background(background)
                .frame(width: size, height: size / Self.aspect)
        }
        .onReceive(video.$coverURL) { coverURL in
            self.imageURL = coverURL
        }
    }

    var background: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary)
            .frame(width: size, height: size / Self.aspect)
    }
}

#Preview {
    GalleryImage(video: .placeholder, size: AppGrid.pt192)
}
