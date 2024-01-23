//
//  ExportPanel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

enum ExportPanel {
    case grab, cut, metadata
    
    var label: some View {
        switch self {
        case .grab:
            Label("Grab", image: "GrabShotInvert")
        case .cut:
            Label("Cut", systemImage: "timeline.selection")
        case .metadata:
            Label("Metadata", systemImage: "list.bullet.clipboard")
        }
    }
}
