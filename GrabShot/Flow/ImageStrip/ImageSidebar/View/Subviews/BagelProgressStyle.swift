//
//  BagelProgressStyle.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct BagelProgressStyle: ProgressViewStyle {
    var strokeColor = Color.accentColor
    var strokeWidth = 10.0
    var maxDiameter = AppGrid.pt48
    
    public func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? .zero
        
        Circle()
            .stroke(.gray.opacity(0.25), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            .frame(maxWidth: maxDiameter, maxHeight: maxDiameter)
            .overlay {
                Circle()
                    .trim(from: 0, to: fractionCompleted)
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(maxWidth: maxDiameter, maxHeight: maxDiameter)
            }
    }
}

extension ProgressViewStyle where Self == BagelProgressStyle {
    
    /// A progress view that visually indicates its progress using a bagel
    /// bar.
    public static var bagel: BagelProgressStyle { .init() }
}
