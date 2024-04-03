//
//  CutExportPanel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

struct CutPropertyPanel: View {
    
    @ObservedObject var video: Video
    
    var body: some View {
        ScrollView {
            Grid(alignment: .leadingFirstTextBaseline) {
                GridRow {
                    Text("Copy the original audio and video without re-encoding into a QuickTime container.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(minWidth: AppGrid.pt256, idealWidth: AppGrid.pt300, maxWidth: AppGrid.pt400)
    }
}

#Preview {
    CutPropertyPanel(video: .placeholder)
}
