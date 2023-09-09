//
//  ItemContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct ItemVideoContextMenu: View {
    
    var video: Video
    @Binding var selection: Set<Video.ID>
    @EnvironmentObject var grabModel: GrabModel
    
    var body: some View {
        Button("Show in Finder", action: { showInFinder(url: video.url, type: .file) })
        
        Button("Show export directory", action: { showInFinder(url: video.exportDirectory, type: .directory) })
            .disabled(video.exportDirectory == nil)
        
        Button("Delete", role: .destructive) {
            if !selection.contains(video.id) {
                deleteAction(ids: [video.id])
            } else {
                deleteAction(ids: selection)
            }
        }
    }
    
    private func showInFinder(url: URL?, type: URLType) {
        guard
            let url
        else { return }
        switch type {
        case .directory:
            FileService.openDirectory(by: url)
        case .file:
            FileService.openFile(for: url)
        }
    }
    
    enum URLType {
        case file, directory
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
