//
//  ExportPicker.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

struct ExportPicker: View {
    
    @Binding var panel: ExportPanel
    
    var body: some View {
        Picker("Export", selection: $panel) {
            ExportPanel.grab.label
                .tag(ExportPanel.grab)
            ExportPanel.cut.label
                .tag(ExportPanel.cut)
            ExportPanel.metadata.label
                .tag(ExportPanel.metadata)
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

#Preview {
    ExportPicker(panel: .constant(.grab))
}
