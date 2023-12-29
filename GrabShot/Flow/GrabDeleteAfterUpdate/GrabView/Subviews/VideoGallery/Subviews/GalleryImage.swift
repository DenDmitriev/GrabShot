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
    @State var width: CGFloat = .zero

    var body: some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: width / Self.aspect)
                .cornerRadius(AppGrid.pt6)
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
            ZStack(content: {
                Image(systemName: "film")
                    .symbolVariant(.fill)
                    .font(.system(size: AppGrid.pt36))
                    .foregroundColor(.gray)
            })
            .frame(width: width, height: width / Self.aspect)
            .background(background)
            
        }
        .frame(maxWidth: .infinity)
        .readSize(onChange: { size in
            width = size.width
            print(size)
        })
        .frame(height: width / Self.aspect)
        .onReceive(video.$coverURL) { coverURL in
            self.imageURL = coverURL
        }
    }

    var background: some View {
        RoundedRectangle(cornerRadius: AppGrid.pt6)
            .fill(.quinary)
    }
}

#Preview {
    GalleryImage(video: .placeholder)
        .padding()
}
