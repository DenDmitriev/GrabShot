//
//  BagelProgressStyle.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import SwiftUI

struct BagelProgressStyle: ProgressViewStyle {
    var strokeColor = Color.accentColor
    var strokeWidth = 10.0
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? .zero
        
        GeometryReader { geometry in
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
