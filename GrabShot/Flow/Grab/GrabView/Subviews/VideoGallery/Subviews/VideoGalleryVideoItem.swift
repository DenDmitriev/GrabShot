//
//  VideoGalleryVideoItem.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI
import AppKit

struct VideoGalleryVideoItem: View {
    var video: Video
    var size: CGFloat
    
    @EnvironmentObject var viewModel: VideosModel
    @Binding var selection: Set<Video.ID>
    @Binding var state: GrabState
    @State var isOn: Bool = false
    
    var body: some View {
        VStack {
            GalleryImage(video: video, size: size)
                .background(selectionBackground)
            
            VStack {
                HStack {
                    VideoToggleItemView(state: $state, video: video)
                    
                    Text(verbatim: video.title)
                        .font(.callout)
                    .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    VideoDurationItemView(video: video, style: .units)
                    
                    Text("for")
                        .foregroundColor(video.isEnable ? .primary : .secondary)
                    
                    VideoShotsCountItemView(video: video, includingText: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    VideoSourceItemView(video: video, includingText: false)
                    VideoOutputItemView(video: video, includingText: false)
                    VideoRangeItemView(video: video, includingText: false, showRangeGlobal: $viewModel.showIntervalSettings)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: size)
    }
    
    var isSelected: Bool {
        selection.contains(video.id)
    }
    
    @ViewBuilder
    var selectionBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: Grid.pt8)
                .stroke(.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }
    
    private struct GalleryImage: View {
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
                    .cornerRadius(Grid.pt8)
                    .background(background)
                    .overlay {
                        if video.progress.current != video.progress.total {
                            VideoGrabProgressItemView()
                                .environmentObject(video.progress)
                                .frame(width: Grid.pt48, height: Grid.pt48)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            video.updateCover()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .padding(Grid.pt4)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(Grid.pt6)
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
                imageURL = coverURL
            }
        }

        var background: some View {
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
                .frame(width: size, height: size / Self.aspect)
        }
    }
}

struct VideoGalleryVideoItem_Previews: PreviewProvider {
    static var previews: some View {
        let video: Video = .placeholder
        let selection: Set<Video.ID> = [video.id]
        VideoGalleryVideoItem(video: video, size: Grid.pt128, selection: .constant(selection), state: .constant(.ready))
            .environmentObject(VideosModel())
    }
}
