//
//  ExportSettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

struct ExportSettingsView: View {
    @ObservedObject var video: Video
    @Binding var exportPanel: VideoExportTab
    
    var body: some View {
        VStack {
            switch exportPanel {
            case .grab:
                // Export settings
                GrabPropertyView(video: video)
                    .tag(VideoExportTab.grab)
            case .cut:
                CutPropertyPanel(video: video)
                    .tag(VideoExportTab.cut)
//            case .metadata:
//                MetadataVideoView(metadata: $video.metadata)
//                    .tag(ExportPanel.metadata)
            }
        }
    }
}

#Preview {
    ExportSettingsView(video: .placeholder, exportPanel: .constant(.grab))
}
