//
//  VideoTable.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct VideoTable: View {
    
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var grabModel: GrabModel
    @ObservedObject var viewModel: VideoTableModel
    @Binding var selection: Set<Video.ID>
    @Binding var state: GrabState
    
    @State var sortOrder: [KeyPathComparator<Video>] = [
        .init(\.id, order: SortOrder.forward)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            Table(selection: $selection, sortOrder: $sortOrder) {
                
                TableColumn("✓", value: \.isEnable, comparator: BoolComparator()) { video in
                    VideoTableColumnToggleItemView(state: $state, video: video)
                        .environmentObject(viewModel)
                }
                .width(max: geometry.size.width / 36)
                
                TableColumn("Title") { video in
                    VideoTableColumnTitleItemView(video: video)
                        .environmentObject(viewModel)
                }
                
                TableColumn("Output") { video in
                    VideoTableColumnOutputItemView(video: video)
                        .environmentObject(viewModel)
                }
                
                TableColumn("Duration") { video in
                    VideoTableColumnDurationItemView(video: video)
                }
                .width(max: geometry.size.width / 10)
                
                TableColumn("Range") {video in
                    VideoTableColumnRangeItemView(video: video)
                }
                .width(max: geometry.size.width / 8)
                
                TableColumn("Shots") { video in
                    VideoTableColumnShotsItemView(video: video)
                }
                .width(max: geometry.size.width / 16)
                
                TableColumn("Progress") { video in
                    VideoTableColumnProgressItemView(video: video)
                }
            } rows: {
                ForEach(viewModel.videos) { video in
                    TableRow(video).contextMenu {
                        Button("Delete", role: .destructive) {
                            if !selection.contains(video.id) {
                                deleteAction(ids: [video.id])
                            } else {
                                deleteAction(ids: selection)
                            }
                        }
                    }
                }
            }
            .groupBoxStyle(DefaultGroupBoxStyle())
            .frame(width: geometry.size.width)
            .alert(isPresented: $viewModel.showAlert, error: viewModel.error) { _ in
                Button("OK", role: .cancel) {
                    print("alert dismiss")
                }
            } message: { error in
                Text(error.recoverySuggestion ?? "")
            }
        }
    }
    
    private func deleteAction(ids: Set<Video.ID>) {
        withAnimation {
            grabModel.didDeleteVideos(by: ids)
            ids.forEach { id in
                selection.remove(id)
            }
        }
    }
}

struct VideoTable_Previews: PreviewProvider {
    static var previews: some View {
        VideoTable(
            viewModel: VideoTableModel(
                videos: Binding<[Video]>.constant([Video(url: URL(string: "folder/video.mov")!)]),
                grabModel: GrabModel()),
            selection: Binding<Set<Video.ID>>.constant(Set<Video.ID>()),
            state: Binding<GrabState>.constant(.ready))
        .environmentObject(VideoStore.shared)
        .environmentObject(GrabModel())
    }
}

private struct BoolComparator: SortComparator {
    typealias Compared = Bool

    func compare(_ lhs: Bool, _ rhs: Bool) -> ComparisonResult {
        switch (lhs, rhs) {
        case (true, false):
            return order == .forward ? .orderedDescending : .orderedAscending
        case (false, true):
            return order == .forward ? .orderedAscending : .orderedDescending
        default: return .orderedSame
        }
    }

    var order: SortOrder = .forward
}
