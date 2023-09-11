//
//  VideoGallery.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct VideoGallery: View {
    
    @State private var itemSize: CGFloat = Grid.pt192
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var grabModel: GrabModel
    @ObservedObject var viewModel: VideosModel
    @Binding var selection: Set<Video.ID>
    @Binding var state: GrabState
    
    @Binding var sortOrder: [KeyPathComparator<Video>]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(videos) { video in
                    VideoGalleryVideoItem(video: video, size: itemSize, selection: $selection, state: $state)
                        .environmentObject(viewModel)
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
}

struct VideoGallery_Previews: PreviewProvider {
    static var previews: some View {
        VideoGallery(
            viewModel: VideosModel(grabModel: GrabModel()),
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
