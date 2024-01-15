//
//  IconButton.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.01.2024.
//

import SwiftUI

struct CircleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 18, height: 18)
            .font(.headline)
            .background(.control)
            .clipShape(Circle())
            .shadow(radius: 0.5, y: 0.5)
    }
}

extension ButtonStyle where Self == CircleButton {
    static var circle: CircleButton { .init() }
}

#Preview("CircleButton") {
    struct PreviewWrapper: View {
        var body: some View {
            HStack {
                Button(action: {
                    print("Button pressed!")
                }, label: {
                    Image(systemName: "plus")
                })
                .buttonStyle(.circle)
                
                Button(action: {
                    print("Button pressed!")
                }, label: {
                    Image(systemName: "minus")
                })
                .buttonStyle(.circle)
            
            }
            .padding()
        }
    }
    
    return VStack {
        PreviewWrapper()
            .environment(\.colorScheme, .light)
        
        PreviewWrapper()
            .environment(\.colorScheme, .dark)
    }
}
