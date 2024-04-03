//
//  ColorPreview.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

struct HierarchicalStylesPreview: View {
    
    struct SystemShapeStyle<Shape>: Identifiable where Shape: ShapeStyle {
        var name: String
        let style: Shape
        
        var id: String {
            name
        }
    }
    
    let systemColors: [SystemShapeStyle] = [
        SystemShapeStyle(name: "Primary", style: .primary),
        SystemShapeStyle(name: "Secondary", style: .secondary),
        SystemShapeStyle(name: "Tertiary", style: .tertiary),
        SystemShapeStyle(name: "Quaternary", style: .quaternary),
        SystemShapeStyle(name: "Quinary", style: .quinary),
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(systemColors) { shapeStyle in
                Rectangle()
                    .fill(shapeStyle.style)
                    .overlay {
                        Text(shapeStyle.name)
                            .font(.title)
                    }
            }
        }
        .padding()
        .background(.background)
        
    }
}

#Preview {
    HStack(spacing: .zero) {
        HierarchicalStylesPreview()
            .environment(\.colorScheme, .light)
        
        HierarchicalStylesPreview()
            .environment(\.colorScheme, .dark)
    }
}
