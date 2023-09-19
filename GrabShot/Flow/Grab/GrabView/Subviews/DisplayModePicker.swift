//
//  DisplayModePicker.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import SwiftUI

struct DisplayModePicker: View {
    
    @Binding var mode: GrabView.ViewMode
    
    var body: some View {
        Picker("Display Mode", selection: $mode) {
            ForEach(GrabView.ViewMode.allCases) { viewMode in
                viewMode.label
            }
        }
        .pickerStyle(.segmented)
    }
}

struct DisplayModePicker_Previews: PreviewProvider {
    static var previews: some View {
        DisplayModePicker(mode: .constant(.table))
    }
}

extension GrabView.ViewMode {
    
    var labelContent: (name: String, systemImage: String) {
        switch self {
        case .table:
            return ("Table", "tablecells")
        case .gallery:
            return ("Gallery", "photo")
        }
    }
    var label: some View {
        let content = labelContent
        return Label(content.name, systemImage: content.systemImage)
    }
}
