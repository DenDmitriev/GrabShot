//
//  StripPalleteView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct StripColorPickerView: View {
    
    @State var colors: [Color] = []
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
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
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
    static let name = NSImage.Name("testImage")
    static var previews: some View {
        StripColorPickerView(colors: [.red, .blue, .green, .purple, .primary, .orange, .accentColor, .brown, .pink])
            .environmentObject(
                ImageStrip(
                    nsImage: Bundle.main.image(forResource: name)!,
                    url: URL(string: "url.com")!)
            )
            .previewLayout(.fixed(width: 300, height: 50))
    }
}
