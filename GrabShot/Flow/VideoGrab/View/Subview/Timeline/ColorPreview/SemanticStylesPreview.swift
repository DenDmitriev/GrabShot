//
//  SemanticStylesPreview.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.01.2024.
//

import SwiftUI

@available(macOS 14.0, *)
struct SemanticStylesPreview: View {
    
    struct SystemShapeStyle<Shape>: Identifiable where Shape: ShapeStyle {
        var name: String
        let style: Shape
        
        var id: String {
            name
        }
    }
    
    let foreground = SystemShapeStyle(name: "Foreground", style: ForegroundStyle.foreground)
    let background = SystemShapeStyle(name: "Background", style: BackgroundStyle.background)
    let selection = SystemShapeStyle(name: "Selection", style: SelectionShapeStyle.selection)
    let separator = SystemShapeStyle(name: "Separator", style: SeparatorShapeStyle.separator)
    let tint = SystemShapeStyle(name: "Tint", style: TintShapeStyle.tint)
    let placeholder = SystemShapeStyle(name: "Placeholder", style: PlaceholderTextShapeStyle.placeholder)
    let fill = SystemShapeStyle(name: "Fill", style: FillShapeStyle.fill)
    let windowBackground = SystemShapeStyle(name: "WindowBackground", style: WindowBackgroundShapeStyle.windowBackground)
    
    
    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(foreground.style)
                .overlay {
                    Text(foreground.name)
                        .font(.title)
                }
            
            Rectangle()
                .fill(placeholder.style)
                .overlay {
                    Text(placeholder.name)
                        .font(.title)
                }
            
            Rectangle()
                .fill(selection.style)
                .overlay {
                    Text(selection.name)
                        .font(.title)
                }
            
            Rectangle()
                .fill(separator.style)
                .overlay {
                    Text(separator.name)
                        .font(.title)
                }
            
            Rectangle()
                .fill(fill.style)
                .overlay {
                    Text(fill.name)
                        .font(.title)
                }
            
            Rectangle()
                .fill(windowBackground.style)
                .overlay {
                    Text(windowBackground.name)
                        .font(.title)
                }
            
            Rectangle()
                .fill(tint.style)
                .overlay {
                    Text(tint.name)
                        .font(.title)
                }
            
            Rectangle()
                .fill(background.style)
                .overlay {
                    Text(background.name)
                        .font(.title)
                }
        }
        .frame(height: 800)
        .padding()
        .background(.background)
        
    }
}

@available(macOS 14.0, *)
#Preview {
    ScrollView {
        HStack(spacing: .zero) {
            VStack {
                Text("Light scheme".uppercased())
                SemanticStylesPreview()
                    .environment(\.colorScheme, .light)
            }
            
            VStack {
                Text("Dark scheme".uppercased())
                SemanticStylesPreview()
                    .environment(\.colorScheme, .dark)
            }
        }
    }
}
