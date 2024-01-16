//
//  IconButton.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.01.2024.
//

import SwiftUI


struct IconButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.secondary)
            .font(.title2.weight(.semibold))
//            .shadow(radius: 1, y: 1)
            .frame(width: AppGrid.pt28, height: AppGrid.pt20)
    }
}

extension ButtonStyle where Self == IconButton {
    static var icon: IconButton { .init() }
}

#Preview("CircleButton") {
    struct PreviewWrapper: View {
        var body: some View {
            HStack {
                Button(action: {
                    print("Button pressed!")
                }, label: {
                    Image(systemName: "play.fill")
                })
                
                Button(action: {
                    print("Button pressed!")
                }, label: {
                    Image(systemName: "chevron.right.to.line")
                })
                
                Button(action: {
                    print("Button pressed!")
                }, label: {
                    Image("GrabShotInvert")
                })
            }
            
            .buttonStyle(.icon)
            .frame(maxWidth: 100, maxHeight: 100)
            .background(.background)
//            .padding()
        }
    }
    
    return VStack(spacing: .zero) {
        PreviewWrapper()
            .environment(\.colorScheme, .light)
        
        PreviewWrapper()
            .environment(\.colorScheme, .dark)
    }
}
