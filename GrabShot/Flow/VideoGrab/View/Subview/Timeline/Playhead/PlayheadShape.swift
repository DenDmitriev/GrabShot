//
//  PlayheadShape.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct PlayheadShape: Shape {
    let head: CGFloat
    let thickness: CGFloat
    let radius: CGFloat = 2
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let point1 = CGPoint(x: rect.maxX, y: rect.minY)
        let point2 = CGPoint(x: rect.midX + thickness / 2, y: rect.minY + head)
        let point3 = CGPoint(x: rect.midX + thickness / 2, y: rect.maxY - radius)
        let point4 = CGPoint(x: rect.midX - thickness / 2, y: rect.minY + head)
        let point5 = CGPoint(x: rect.minX, y: rect.minY)

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY), radius: thickness / 2, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: point4)
        path.addArc(tangent1End: point5, tangent2End: point1, radius: radius)
        path.closeSubpath()

        return path
    }
}

#Preview(body: {
    PlayheadShape(head: 20, thickness: 4)
        .frame(width: 25, height: 40)
        .padding()
})
