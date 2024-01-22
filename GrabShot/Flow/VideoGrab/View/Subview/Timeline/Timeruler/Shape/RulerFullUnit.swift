//
//  RulerFullUnit.swift
//  Timeruler
//
//  Created by Denis Dmitriev on 21.01.2024.
//

import SwiftUI

struct RulerFullUnit: Shape {
    let units: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = rect.minX
        
        path.move(to: CGPoint(x: x, y: rect.minY))
        path.addLine(to: CGPoint(x: x, y: rect.maxY))
        
        return path
    }
    
    private func isEven(_ unit: Int) -> Bool {
        unit % 2 == .zero
    }
}

#Preview {
    VStack {
        RulerFullUnit(units: 5)
            .stroke(.secondary, lineWidth: 1)
            .background(.pink.opacity(0.1))
    }
    .frame(width: 100, height: 30)
    .padding()
}
