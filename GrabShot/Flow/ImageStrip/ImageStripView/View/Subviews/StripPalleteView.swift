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
        GeometryReader { geometry in
            HStack(spacing: .zero) {
                if colors.count != .zero {
                    ForEach(0...colors.index(before: colors.count), id: \.self) { number in
                        Rectangle()
                            .fill(colors[number])
                            .overlay(alignment: .center) {
                                if showPickers {
                                    ColorPicker("Pick color", selection: $colors[number])
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
}


struct StripPalleteView_Previews: PreviewProvider {
    static var previews: some View {
        StripPalleteView(colors: Binding<[Color]>.constant([.red, .blue]))
    }
}
