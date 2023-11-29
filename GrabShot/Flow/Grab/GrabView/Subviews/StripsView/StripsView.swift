//
//  StripsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct StripsView: View {
    
    @Binding var sortOrder: [KeyPathComparator<Video>]
    @EnvironmentObject var videoStore: VideoStore
    @Binding var selection: Set<Video.ID> // viewModel.$selection
    @Binding var grabbingId: Video.ID? // viewModel.grabbingID
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        ForEach(videos) { video in
                            StripView(viewModel: StripModel(video: video), showCloseButton: false)
                                .frame(height: geometry.size.height + (Grid.pt8))
                        }
                    }
                    
                }
                .onChange(of: selection, perform: { selection in
                    guard let index = selection.first else { return }
                    withAnimation {
                        proxy.scrollTo(index)
                    }
                })
                .onChange(of: grabbingId) { grabbed in
                    guard let index = grabbed else { return }
                    withAnimation {
                        proxy.scrollTo(index)
                    }
                }
            }
            .padding(.all, -Grid.pt4)
        }
    }
}

extension StripsView {
    var videos: [Video] {
        return videoStore.sortedVideos
    }
}

struct StripsView_Previews: PreviewProvider {
    static let id = UUID()
    static var previews: some View {
        let store = VideoStore()
        StripsView(sortOrder: .constant([KeyPathComparator<Video>(\.title, order: SortOrder.forward)]), selection: .constant(Set<Video.ID>()), grabbingId: .constant(id))
            .environmentObject(store)
    }
}
