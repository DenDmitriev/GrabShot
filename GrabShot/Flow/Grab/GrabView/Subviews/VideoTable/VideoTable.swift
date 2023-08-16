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
    
    private func isDisabled(by state: GrabState) -> Bool {
        switch state {
        case .ready, .canceled, .complete:
            return false
        case .calculating, .grabbing, .pause:
            return true
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Table(viewModel.videos, selection: $selection) {
                
                TableColumn("✓") { video in
                    if let isOn = $viewModel.videos.first(where: { $0.id == video.id })?.isEnable {
                        Toggle(isOn: isOn) {
                            EmptyView()
                        }
                        .disabled(isDisabled(by: state))
                        .toggleStyle(.checkbox)
                    }
                }
                .width(max: geometry.size.width / 36)
                
                TableColumn("Title") { video in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(video.title)
                    }
                    .foregroundColor(video.isEnable ? .primary : .gray)
                }

                TableColumn("Path") { video in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Button {
                            viewModel.openVideoFile(by: video.url)
                        } label: {
                            Text(video.url.relativePath)
                                .foregroundColor(selection.contains(video.id) ? .white : .blue)
                        }
                        .buttonStyle(.link)
                    }
                }

                TableColumn("Duration") { video in
                    Text(DurationFormatter.string(video.duration))
                        .foregroundColor(video.isEnable ? .primary : .gray)
                }
                .width(max: geometry.size.width / 12)

                TableColumn("Shots") { video in
                    Text(video.progress.total.formatted(.number))
                        .foregroundColor(video.isEnable ? .primary : .gray)
                }
                .width(max: geometry.size.width / 16)

                TableColumn("Progress") { video in
                    ProgressView(
                        value: Double(video.progress.current),
                        total: Double(video.progress.total)
                    )
                    .tint(video.isEnable ? .accentColor : .gray)
                }
            }
            .groupBoxStyle(DefaultGroupBoxStyle())
            .frame(width: geometry.size.width)
        }
    }
}

struct VideoTable_Previews: PreviewProvider {
    static var previews: some View {
        VideoTable(viewModel: VideoTableModel(videos: Binding<[Video]>.constant([Video(url: URL(string: "folder/video.mov")!)])), selection: Binding<Set<Video.ID>>.constant(Set<Video.ID>()), state: Binding<GrabState>.constant(.ready))
            .environmentObject(Session.shared)
    }
}
