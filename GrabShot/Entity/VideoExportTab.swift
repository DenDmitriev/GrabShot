//
//  ExportPanel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

enum VideoExportTab {
    case grab, cut//, metadata
    
    var name: String {
        switch self {
        case .grab:
            String(localized:"Grab")
        case .cut:
            String(localized:"Cut")
        }
    }
    
    var image: Image {
        switch self {
        case .grab:
            Image("GrabShotInvert")
        case .cut:
            Image(systemName: "timeline.selection")
        }
    }
    
    var label: some View {
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: AppGrid.pt16)
            
            Text(name)
        }
    }
}

extension VideoExportTab: CaseIterable, Identifiable, Hashable {
    var id: Self {
        self
    }
}

#Preview(body: {
    HStack {
        ForEach(VideoExportTab.allCases) { panel in
            panel.label
        }
    }
    .padding()
})
