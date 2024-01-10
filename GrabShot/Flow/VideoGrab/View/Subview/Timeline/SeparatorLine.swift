//
//  SeporatorLine.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.01.2024.
//

import SwiftUI

struct SeparatorLine: View {
    var body: some View {
        VStack(spacing: .zero) {
            ZStack {
                Rectangle()
                    .fill(.deep)
                .frame(height: AppGrid.pt1)
                
                Rectangle()
                    .fill(.bevel.opacity(0.5))
                    .frame(height: AppGrid.pt1)
                    .offset(y: 1)
            }
        }
    }
}

#Preview {
    SeparatorLine()
        .frame(width: 300)
        .padding()
}
