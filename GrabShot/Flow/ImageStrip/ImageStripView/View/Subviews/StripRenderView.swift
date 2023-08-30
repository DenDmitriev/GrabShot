//
//  StripRenderView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.08.2023.
//

import SwiftUI

struct StripRenderView: View {
    
    var colors: [Color]
    
    var body: some View {
        HStack(spacing: .zero) {
            ForEach(colors.indices, id: \.self) { index in
                Rectangle()
                    .fill(colors[index])
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct StripRenderView_Previews: PreviewProvider {
    static var previews: some View {
        StripRenderView(colors: [.red, .blue, .yellow])
    }
}
