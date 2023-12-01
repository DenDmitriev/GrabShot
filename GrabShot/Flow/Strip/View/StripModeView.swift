//
//  StripModeView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2023.
//

import SwiftUI

struct StripModeView: View {
    
    let mode: StripMode
    
    var body: some View {
        HStack {
            mode.placeholder
            Text(mode.name)
        }
    }
}

extension StripMode {
    @ViewBuilder
    var placeholder: some View {
        switch self {
        case .strip:
            Image(nsImage: NSImage(named: "strip")!)
        case .gradient:
            Image(nsImage: NSImage(named: "gradient")!)
        }
    }
}

#Preview(StripMode.strip.name) {
    StripModeView(mode: .strip)
}

#Preview(StripMode.gradient.name) {
    StripModeView(mode: .gradient)
}
