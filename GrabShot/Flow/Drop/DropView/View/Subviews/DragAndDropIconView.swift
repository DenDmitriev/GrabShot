//
//  DragAndDropIconView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI

struct DragAndDropIconView: View {
    
    @State var color: Color
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                
                let adjasment = geometry.size.width / 10
                
                Image("drop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: adjasment * 3, alignment: .center)
                    .foregroundColor(color)
                
                RoundedRectangle(cornerRadius: adjasment)
                    .stroke(style: StrokeStyle(
                        lineWidth: adjasment / 4,
                        lineCap: .round,
                        dash: [adjasment / 1.5],
                        dashPhase: adjasment / 5))
                    .frame(width: geometry.size.height, height: geometry.size.height, alignment: .center)
                    .foregroundColor(color)
            }
        }
    }
}

struct BadgeBackground_Previews: PreviewProvider {
    static var previews: some View {
        DragAndDropIconView(color: .gray)
            .previewLayout(.fixed(width: Grid.pt256, height: Grid.pt256))
    }
}
