//
//  DropZoneView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.08.2023.
//

import SwiftUI

struct DropZoneView: View {
    
    enum ViewMode {
        case video, image
    }
    
    @Binding var isAnimate: Bool
    @Binding var showDropZone: Bool
    @State var mode: ViewMode
    
    var body: some View {
        ZStack {
            switch mode {
            case .video:
                DropVideoIcon()
            case .image:
                DropImageIcon()
            }
            
            RoundedRectangle(cornerRadius: AppGrid.pt8)
                .stroke(style: StrokeStyle(
                    lineWidth: AppGrid.pt2,
                    lineCap: .round,
                    dash: [AppGrid.pt10, AppGrid.pt6],
                    dashPhase: isAnimate ? AppGrid.pt16 : 0)
                )
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .animation(.linear(duration: 0.5).repeatForever(autoreverses: false), value: isAnimate
                )
                .opacity(showDropZone ? 1 : 0)
        }
    }
}

struct DropZoneView_Previews: PreviewProvider {
    static var previews: some View {
        DropZoneView(isAnimate: .constant(true), showDropZone: .constant(true), mode: .video)
    }
}
