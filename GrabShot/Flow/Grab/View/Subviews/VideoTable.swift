//
//  VideoTable.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct VideoTable: View {
    
    @ObservedObject var viewModel: GrabModel
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            
            Table(viewModel.session.videos, selection: $viewModel.selection) {
                
                TableColumn("ID") { video in
                    Text("\(video.id + 1)") //нумерацию с 1
                }
                .width(max: width/24)
                
                TableColumn("Title") { video in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(video.title)
                    }
                }
                
                TableColumn("Path") { video in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Button {
                            viewModel.videoService.fileService.openFile(for: video.url)
                        } label: {
                            Text(video.url.relativePath)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.link)
                    }
                }
                
                TableColumn("Duration", value: \.durationString)
                    .width(max: width/12)
                
                TableColumn("Shots") { video in
                    Text("\(video.shots + 1)")  //добавляем нулевой шот
                }
                .width(max: width/16)
                
                TableColumn("Progress") { video in
                    ProgressView(value: video.progress, total: Double(video.shots + 1))
                }
            }
            .groupBoxStyle(DefaultGroupBoxStyle())
            .frame(width: geometry.size.width)
        }
    }
}

struct VideoTable_Previews: PreviewProvider {
    static var previews: some View {
        VideoTable(viewModel: GrabModel())
    }
}
