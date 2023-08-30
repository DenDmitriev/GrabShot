//
//  StripPalleteView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct StripColorPickerView: View {
    
    @State var colors: [Color]
    @EnvironmentObject var imageStrip: ImageStrip
    
    init(colors: [Color]) {
        self.colors = colors
    }
    
    var body: some View {
        HStack(spacing: .zero) {
            if colors.count != .zero {
                ForEach(colors.indices, id: \.self) { index in
                    ColorPickerItem(bgColor: $colors[index])
                }
            }
        }
        .onReceive(imageStrip.$colors, perform: { newColors in
            colors = newColors
        })
        .onChange(of: colors) { newColors in
            imageStrip.colors = newColors
        }
    }
}


struct StripPalleteView_Previews: PreviewProvider {
    static var previews: some View {
        StripColorPickerView(colors: [.red, .blue])
            .environmentObject(
                ImageStrip(
                    nsImage: NSImage(systemSymbolName: "photo", accessibilityDescription: nil)!,
                    url: URL(string: "url.com")!)
            )
    }
}
