//
//  StripPalleteView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct StripPalleteView: View {
    
    @Binding var colors: [Color]
    @State var showPickers: Bool
    
    init(colors: Binding<[Color]>, showPickers: Bool = true) {
        self._colors = colors
        self.showPickers = showPickers
    }
    
    var body: some View {
        HStack(spacing: .zero) {
            if colors.count != .zero {
                ForEach(Array(zip(colors.indices, colors)), id: \.1) { index, color in
                    ZStack {
                        Rectangle()
                            .fill(color)
                        
                        if showPickers {
                            let bindingColor: Binding<Color> = .init(
                                get: { color },
                                set: { color in colors[index] = color }
                            )
                            ColorPicker("Pick color", selection: bindingColor)
                                .pickerStyle(.radioGroup)
                                .labelsHidden()
                                .shadow(radius: Grid.pt8)
                        }
                    }
                }
            }
        }
    }
}


struct StripPalleteView_Previews: PreviewProvider {
    static var previews: some View {
        StripPalleteView(colors: Binding<[Color]>.constant([.red, .blue]))
    }
}
