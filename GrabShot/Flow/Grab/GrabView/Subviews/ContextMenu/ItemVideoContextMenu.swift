//
//  ItemContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct ItemVideoContextMenu: View {
    
    enum URLType {
        case file, directory
    }
    
    var video: Video
    @Binding var selection: Set<Video.ID>
    @EnvironmentObject var grabModel: GrabModel
    @EnvironmentObject var videosModel: VideosModel
    
    var body: some View {
        Button(video.isEnable ? "Disable" : "Enable") {
            toggle(video: video)
        }
        
        Button("Grabbing range") {
            showGrabbingRange()
        }
        
        Divider()
        
        Button("Show in Finder", action: { showInFinder(url: video.url, type: .file) })
        
        Button("Show export directory", action: { showInFinder(url: video.exportDirectory, type: .directory) })
            .disabled(video.exportDirectory == nil)
        
        Divider()
        
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
    
    private func deleteAction(ids: Set<Video.ID>) {
        withAnimation {
            grabModel.didDeleteVideos(by: ids)
            ids.forEach { id in
                selection.remove(id)
            }
        }
    }
    
    private func toggle(video: Video) {
        video.isEnable.toggle()
        grabModel.toggleGrabButton()
    }
    
    private func showGrabbingRange() {
        videosModel.showIntervalSettings.toggle()
    }
}
