//
//  ViewModifireMagnificationEffect.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.01.2024.
//

import SwiftUI

extension View {
    /// https://www.youtube.com/watch?app=desktop&v=kEr_K_kd4RI
    func magnificationGlass(_ scale: CGFloat, _ size: CGSize, shape: some Shape = Circle(), _ tint: Color = .accentColor) -> some View {
        MagnificationGlassHelper(scale: scale, size: size, shape: shape) {
            self
        }
    }
}

fileprivate struct MagnificationGlassHelper<Content: View, Glass: Shape>: View {
    var scale: CGFloat
    var size: CGSize
    var shape: Glass
    var tint: Color
    
    var content: Content
    
    // Gesture properties
    @State var offset: CGSize = .zero
    @State var lastStoredOffset: CGSize = .zero
    
    
    init(scale: CGFloat, size: CGSize, shape: Glass, tint: Color = .accentColor, @ViewBuilder content: @escaping () -> Content) {
        self.scale = scale
        self.size = size
        self.shape = shape
        self.tint = tint
        self.content = content()
    }
    
    var body: some View {
        content
        // Applying reverse mask for clipping the current highlighting
            .reverseMask(content: {
                shape
                    .frame(width: size.width, height: size.height)
                    .offset(offset)
            })
            .overlay {
                GeometryReader { geometry in
                    let glassSize = CGSize(width: size.width, height: size.height)
                    content
                    // Size
                        .frame(width: glassSize.width, height: glassSize.height)
                    // Moving content inside with reversing
                        .offset(x: -offset.width, y: -offset.height)
                    // Scale effect
                        .scaleEffect(1 + scale)
                        .clipShape(shape)
                    // Applying offset
                        .offset(offset)
                    // To center
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .shadow(radius: 10)
                    
                    shape
                        .fill(.clear)
                        .frame(width: glassSize.width, height: glassSize.height)
                        .overlay(alignment: .topLeading, content: {
                            shape
                                .stroke(tint, lineWidth: 3)
                                .offset(offset)
                        })
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        offset = CGSize(width: value.translation.width + lastStoredOffset.width, height: value.translation.height + lastStoredOffset.height)
                    })
                    .onEnded({ value in
                        lastStoredOffset = value.translation
                    })
            )
    }
}

extension View {
    // Reverse mask modifier
    func reverseMask<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .mask {
                Rectangle()
                    .overlay {
                        content()
                            .blendMode(.destinationOut)
                    }
            }
    }
    
}
