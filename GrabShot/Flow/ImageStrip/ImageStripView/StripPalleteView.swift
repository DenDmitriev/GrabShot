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
        HStack(spacing: .zero) {
            ForEach(0..<count, id: \.self) { number in
                if 0..<colors.count ~= number  {
                    Rectangle()
                        .fill(colors[number])
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
