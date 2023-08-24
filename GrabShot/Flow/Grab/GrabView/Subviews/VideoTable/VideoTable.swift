//
//  VideoTable.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct VideoTable: View {
    
    @EnvironmentObject var session: Session
    @ObservedObject var viewModel: VideoTableModel
    @Binding var selection: Set<Video.ID>
    @Binding var state: GrabState
    
    var body: some View {
        GeometryReader { geometry in
            Table(viewModel.videos, selection: $selection) {
                TableColumn("✓") { video in
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
}

struct VideoTable_Previews: PreviewProvider {
    static var previews: some View {
        VideoTable(
            viewModel: VideoTableModel(
                videos: Binding<[Video]>.constant([Video(url: URL(string: "folder/video.mov")!)]),
                grabModel: GrabModel()),
            selection: Binding<Set<Video.ID>>.constant(Set<Video.ID>()),
            state: Binding<GrabState>.constant(.ready))
        .environmentObject(Session.shared)
        .environmentObject(GrabModel())
    }
}
