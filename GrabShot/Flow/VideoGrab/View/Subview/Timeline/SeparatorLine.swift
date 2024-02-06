//
//  SeporatorLine.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.01.2024.
//

import SwiftUI

struct SeparatorLine: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Rectangle()
            .fill(style(scheme: colorScheme))
            .frame(height: AppGrid.pt1)
    }
    
    private func style(scheme: ColorScheme) -> AnyShapeStyle {
        switch scheme {
        case .light:
            AnyShapeStyle(SeparatorShapeStyle.separator)
        case .dark:
            AnyShapeStyle(BackgroundStyle.background)
        @unknown default:
            AnyShapeStyle(SeparatorShapeStyle.separator)
        }
    }
}

#Preview {
    SeparatorLine()
        .frame(width: 300)
        .padding()
}
