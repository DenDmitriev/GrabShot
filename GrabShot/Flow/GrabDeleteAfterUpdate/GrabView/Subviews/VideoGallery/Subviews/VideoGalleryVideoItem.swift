//
//  VideoGalleryVideoItem.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI
import AppKit

struct VideoGalleryVideoItem: View {
    @State var video: Video
    var size: CGFloat
    
    @EnvironmentObject var viewModel: VideosModel
    @Binding var selection: Set<Video.ID>
    @Binding var state: GrabState
    @State var isOn: Bool = false
    
    var body: some View {
        VStack {
            GalleryImage(video: video, width: size)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        updateCover()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .padding(AppGrid.pt4)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.borderless)
                    .padding(AppGrid.pt6)
                }
                .onAppear {
                    updateCover()
                }
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
                    
                    VideoShotsCountItemView(video: video)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    VideoSourceItemView(video: video, includingText: false)
                    VideoOutputItemView(video: video, includingText: false)
                    VideoRangeItemView(video: video, includingText: false)
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
            RoundedRectangle(cornerRadius: AppGrid.pt8)
                .stroke(.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }
    
    private func updateCover() {
        viewModel.updateCover(video: video)
    }
}

struct VideoGalleryVideoItem_Previews: PreviewProvider {
    static var previews: some View {
        let video: Video = .placeholder
        let selection: Set<Video.ID> = [video.id]
        VideoGalleryVideoItem(video: video, size: AppGrid.pt128, selection: .constant(selection), state: .constant(.ready))
            .environmentObject(VideosModel())
    }
}
