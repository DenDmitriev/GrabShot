//
//  VideoGallery.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct VideoGallery: View {
    
    @State private var itemSize: CGFloat = Grid.pt128
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var grabModel: GrabModel
    @ObservedObject var viewModel: VideoTableModel
    @Binding var selection: Set<Video.ID>
    @Binding var state: GrabState
    
    @Binding var sortOrder: [KeyPathComparator<Video>]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(videos) { video in
                    GalleryItem(video: video, size: itemSize, selection: $selection)
                        .contextMenu {
                            ItemVideoContextMenu(video: video, selection: $selection)
                                .environmentObject(grabModel)
                        }
                }
            }
        }
        .contextMenu {
            VideosContextMenu(selection: $selection)
                .environmentObject(grabModel)
                .environmentObject(videoStore)
        }
    }
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: itemSize, maximum: itemSize), spacing: 40)]
    }
    
    private struct GalleryItem: View {
        
        var video: Video
        var size: CGFloat
        @Binding var selection: Set<Video.ID>
        
        var body: some View {
            VStack {
                GalleryImage(video: video, size: size)
                    .background(selectionBackground)
                Text(verbatim: video.title)
                    .font(.callout)
                    .lineLimit(1)
            }
            .frame(width: size)
            .onTapGesture {
                selection = [video.id]
            }
        }
        
        var isSelected: Bool {
            selection.contains(video.id)
        }
        
        @ViewBuilder
        var selectionBackground: some View {
            if isSelected {
                RoundedRectangle(cornerRadius: Grid.pt8)
                    .fill(.selection)
            }
        }
    }
    
    private struct GalleryImage: View {
        var video: Video
        var size: CGFloat

        var body: some View {
            AsyncImage(url: video.thumbURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .background(background)
                    .frame(width: size, height: size)
            } placeholder: {
                Image(systemName: "film")
                    .symbolVariant(.fill)
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .background(background)
                    .frame(width: size, height: size)
            }
        }

        var background: some View {
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
                .frame(width: size, height: size)
        }
    }
}

struct VideoGallery_Previews: PreviewProvider {
    static var previews: some View {
        VideoGallery(
            viewModel: VideoTableModel(grabModel: GrabModel()),
            selection: Binding<Set<Video.ID>>.constant(Set<Video.ID>()),
            state: Binding<GrabState>.constant(.ready), sortOrder: .constant([KeyPathComparator<Video>(\.title, order: SortOrder.forward)])
        )
        .environmentObject(VideoStore.shared)
        .environmentObject(GrabModel())
    }
}

extension VideoGallery {
    var videos: [Video] {
        return videoStore.sortedVideos
    }
}
