//
//  RulerHalfUnit.swift
//  Timeruler
//
//  Created by Denis Dmitriev on 21.01.2024.
//

import SwiftUI

struct RulerHalfUnit: Shape {
    let units: Int
    
    private var isEven: Bool {
        units % 2 == .zero
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isEven {
            let x = rect.midX
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY * 0.75))
        }
        
        return path
    }
}

#Preview {
    VStack {
        RulerHalfUnit(units: 6)
            .stroke(.secondary, lineWidth: 1)
            .background(.pink.opacity(0.1))
        
        RulerHalfUnit(units: 5)
            .stroke(.secondary, lineWidth: 1)
            .background(.pink.opacity(0.1))
    }
    .frame(width: 100, height: 30)
    .padding()
}
