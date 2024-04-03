//
//  RulerThirdUnit.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 26.01.2024.
//

import SwiftUI

struct RulerThirdUnit: Shape {
    let units: Int
    
    private var isThird: Bool {
        units % 3 == .zero
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if isThird {
            var x = rect.minX
            let distance = rect.width / 3
            x += distance
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY * 0.75))
            
            x += distance
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY * 0.75))
        }
        
        return path
    }
}

#Preview {
    VStack {
        RulerThirdUnit(units: 6)
            .stroke(.secondary, lineWidth: 1)
            .background(.pink.opacity(0.1))
        
        RulerThirdUnit(units: 9)
            .stroke(.secondary, lineWidth: 1)
            .background(.pink.opacity(0.1))
    }
    .frame(width: 100, height: 30)
    .padding()
}
