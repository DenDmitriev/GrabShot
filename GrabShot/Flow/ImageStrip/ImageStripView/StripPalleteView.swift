//
//  StripPalleteView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct StripPalleteView: View {
    
    @State var count: Int
    @State var colors: [Color]
    
    init(
        count: Int,
        colors: [Color] = [
            .red,
            .orange,
            .yellow,
            .green,
            .cyan,
            .blue,
            .indigo,
            .purple
        ]
    ) {
        self.count = count
        self.colors = colors
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: .zero) {
                ForEach(0..<count, id: \.self) { number in
                    Rectangle()
                        .fill(colors[number])
                        .overlay(alignment: .center) {
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


struct StripPalleteView_Previews: PreviewProvider {
    static var previews: some View {
        StripPalleteView(count: 8)
    }
}
