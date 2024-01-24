//
//  ExportControl.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 24.01.2024.
//

import SwiftUI

struct ExportControl: View {
    
    @ObservedObject var video: Video
    @Binding var exportPanel: VideoExportTab
    
    var body: some View {
        switch exportPanel {
        case .grab:
            GrabExportControl(video: video)
        case .cut:
            CutExportControl(video: video)
        }
    }
}

#Preview {
    let videoStore = VideoStore()
    let scoreController = ScoreController(caretaker: Caretaker())
    let viewModel = VideoGrabViewModel.build(store: videoStore, score: scoreController)
    
    return ExportControl(video: .placeholder, exportPanel: .constant(.grab))
        .environmentObject(viewModel)
}
