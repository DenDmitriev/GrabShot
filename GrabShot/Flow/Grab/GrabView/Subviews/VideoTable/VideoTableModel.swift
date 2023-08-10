//
//  VideoTableModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.08.2023.
//

import SwiftUI

class VideoTableModel: ObservableObject {
    
    @Published var videos: [Video]
    
    init(videos: [Video]) {
        self.videos = videos
    }
    
    func openVideoFile(by path: URL) {
        FileService.shared.openFile(for: path)
    }
}
