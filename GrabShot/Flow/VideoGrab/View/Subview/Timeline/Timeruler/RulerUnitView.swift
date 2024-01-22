//
//  RulerUnitView.swift
//  Timeruler
//
//  Created by Denis Dmitriev on 21.01.2024.
//

import SwiftUI

struct RulerUnitView: View {
    let units: Int
    let label: String
    
    private static let styleFull = LinearGradient(
        colors: [.secondary.opacity(0.75), .clear],
        startPoint: UnitPoint(x: .zero, y: .zero),
        endPoint: UnitPoint(x: .zero, y: 1)
    )
    private static let styleHalf = LinearGradient(
        colors: [.secondary.opacity(0.5), .clear],
        startPoint: UnitPoint(x: .zero, y: .zero),
        endPoint: UnitPoint(x: .zero, y: 0.5)
    )
    private static let minWidthUnit: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RulerFullUnit(units: units)
                    .stroke(Self.styleFull, lineWidth: 1.0)
                
                if showHalfUnits(width: geometry.size.width) {
                    RulerHalfUnit(units: units)
                        .stroke(Self.styleHalf, lineWidth: 1.0)
                }
                
                if showUnits(width: geometry.size.width) {
                    RulerUnit(units: units)
                        .stroke(.quinary, lineWidth: 1.0)
                }
                
                if showLabel(width: geometry.size.width, units: units) {
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.leading, 4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
        }
    }
    
    private func showUnits(width: CGFloat) -> Bool {
        width / CGFloat(units) >= Self.minWidthUnit
    }
    
    private func showHalfUnits(width: CGFloat) -> Bool {
        width / 2 >= Self.minWidthUnit
    }
    
    private func showLabel(width: CGFloat, units: Int) -> Bool {
        width >= Self.minWidthUnit * CGFloat(units)
    }
}

#Preview {
    RulerUnitView(units: 24, label: "1 seconds")
        .frame(width: 300, height: 30)
//        .background(.pink.opacity(0.1))
        .padding()
}

