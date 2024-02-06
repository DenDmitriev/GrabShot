//
//  RulerUnit.swift
//  Timeruler
//
//  Created by Denis Dmitriev on 21.01.2024.
//

import SwiftUI

struct RulerUnit: Shape {
    let units: Int
    private var isEven: Bool {
        units % 2 == .zero
    }
    
    func path(in rect: CGRect) -> Path {
        let distance = rect.width / CGFloat(units)
        var path = Path()
        var x = rect.minX
        x += distance
        for unit in 1..<units {
            
            if isEven, unit == units / 2 {
                x += distance
                continue
            } else {
                if isEven {
                    if isEven(unit) {
                        path.move(to: CGPoint(x: x, y: rect.minY))
                        path.addLine(to: CGPoint(x: x, y: rect.midY / 2))
                    } else {
                        path.move(to: CGPoint(x: x, y: rect.minY))
                        path.addLine(to: CGPoint(x: x, y: rect.midY / 4))
                    }
                } else {
                    path.move(to: CGPoint(x: x, y: rect.minY))
                    path.addLine(to: CGPoint(x: x, y: rect.midY / 2))
                }
                
                x += distance
            }
        }
        
        return path
    }
    
    private func isEven(_ unit: Int) -> Bool {
        unit % 2 == .zero
    }
}

#Preview {
    VStack {
        RulerUnit(units: 5)
            .stroke(.secondary, lineWidth: 1)
            .background(.pink.opacity(0.1))
        
        RulerUnit(units: 10)
            .stroke(.secondary, lineWidth: 1)
            .background(.pink.opacity(0.1))
    }
    .frame(width: 100, height: 30)
    .padding()
}
