//
//  TimeUnit.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct TimeUnit: Shape {
    
    let ticks: [TimeTick]
    
    func path(in rect: CGRect) -> Path {
        let distance = rect.width / CGFloat(ticks.count)
        var path = Path()
        var x = rect.minX
        for tick in ticks {
            switch tick {
            case .major:
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.maxY))
            case .mid:
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.midY / 2))
            case .minor:
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.midY / 4))
            }
            x += distance
        }
        return path
    }
}

enum TimeTick {
    case major, mid, minor
}

#Preview {
    HStack {
        ForEach(0...0, id: \.self) { num in
            TimeUnit(ticks: [.major, .minor, .mid, .minor])
                .stroke(.secondary, lineWidth: 1)
                .overlay(alignment: .bottomLeading) {
                    Text(Duration.seconds(num).formatted(.timecode(frameRate: 25)))
                        .padding(.leading, 4)
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                }
                .frame(width: 140)
        }
    }
    .frame(height: 30)
    .padding()
}
