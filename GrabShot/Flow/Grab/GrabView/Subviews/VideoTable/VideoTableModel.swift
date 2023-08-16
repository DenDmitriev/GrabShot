//
//  VideoTableModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.08.2023.
//

import SwiftUI

class VideoTableModel: ObservableObject {
    
    @Binding var videos: [Video]
    
    init(videos: Binding<[Video]>) {
        self._videos = videos
    }
    
    func openVideoFile(by path: URL) {
        FileService.shared.openFile(for: path)
    }
    
    func shot(for video: Video) {
        video.updateShots()
    }
}
