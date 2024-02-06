//
//  ViewModifireMagnificationEffect.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.01.2024.
//

import SwiftUI

extension View {
    /// https://www.youtube.com/watch?app=desktop&v=kEr_K_kd4RI
    func magnification(
        title: String = "",
        scale: CGFloat,
        size: CGSize,
        shape: some Shape = Circle(),
        color tint: Color = .accentColor,
        position: CGSize,
        padding: CGFloat = 12,
        alignment: Alignment = .top,
        isShow: Binding<Bool> = .constant(true)
    ) -> some View {
        MagnificationHelper(
            scale: scale,
            size: size,
            shape: shape,
            position: position,
            title: title,
            padding: padding,
            alignment: alignment,
            isShow: isShow
        ) { self }
    }
}

fileprivate struct MagnificationHelper<Content: View, Glass: Shape>: View {
    var scale: CGFloat
    var size: CGSize
    var shape: Glass
    var tint: Color
    var position: CGSize
    var content: Content
    @State var offset: CGSize = .zero
    @State var labelSize: CGSize = .zero
    var title: String = "Title"
    var alignment: Alignment
    var textPadding: CGFloat
    var borderLineWidth: CGFloat = 3
    @Binding var isShow: Bool
    @State private var opacity: Double = .zero
    @State private var proxyScale: Double = .zero
    
    init(scale: CGFloat, size: CGSize, shape: Glass, tint: Color = .accentColor, position: CGSize, title: String, padding: CGFloat, alignment: Alignment, isShow: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.scale = scale
        self.size = size
        self.shape = shape
        self.tint = tint
        self.position = position
        self.title = title
        self.alignment = alignment
        self.textPadding = padding
        self._isShow = isShow
        self.content = content()
    }
    
    var body: some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let glassSize = CGSize(width: size.width, height: size.height)
                    
                    content
                        .readSize(onChange: { size in
                            offset = CGSize(
                                width: -size.width / 2 + (size.width * position.width),
                                height: -size.height / 2 + (size.height * position.height))
                        })
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    // Size
                        .frame(width: glassSize.width, height: glassSize.height)
                    // Moving content inside with reversing
                        .offset(x: -offset.width, y: -offset.height)
                    // Scale effect
                        .scaleEffect(1 + proxyScale)
                        .animation(.spring.delay(0.5), value: proxyScale)
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
                                .stroke(tint, lineWidth: borderLineWidth)
                                .offset(offset)
                                .overlay(alignment: alignment) {
                                    if !title.isEmpty {
                                        let textOffset = getTextOffset(alignment: alignment, padding: textPadding)
                                        
                                        Text(title)
                                            .font(.headline)
                                            .offset(textOffset)
                                            .padding(8)
                                            .readSize(onChange: { size in
                                                labelSize = size
                                            })
                                            .background {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(.background)
                                                    .offset(textOffset)
                                                    .shadow(radius: 10)
                                            }
                                            .background {
                                                let lineOffset = getLineOffset(alignment: alignment, padding: textPadding)
                                                
                                                let direction = getDirection(alignment: alignment)
                                                
                                                Line(direction: direction)
                                                    .stroke(tint, lineWidth: borderLineWidth)
                                                    .frame(width: textPadding, height: textPadding)
                                                    .offset(textOffset)
                                                    .offset(lineOffset)
                                            }
                                    }
                                }
                        })
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .opacity(opacity)
                .animation(.spring, value: opacity)
                .transition(.slide)
                .onAppear {
                    proxyScale = isShow ? scale : 0
                    opacity = isShow ? 1 : 0
                }
                .onChange(of: isShow) { isShow in
                    opacity = isShow ? 1 : 0
                    proxyScale = isShow ? scale : 0
                }
            }
    }
    
    private func getTextOffset(alignment: Alignment, padding: CGFloat) -> CGSize {
        let paddingHorizontal = padding + labelSize.width
        let paddingVertical = padding + labelSize.height
        let diagonalHPadding = size.width / 2 * (sqrt(2) - 1) * sin(45)
        let diagonalVPadding = size.height / 2 * (sqrt(2) - 1) * sin(45)
        switch alignment {
        case .topLeading:
            return CGSize(width: offset.width - paddingHorizontal * sin(45), height: offset.height - paddingVertical * sin(45))
        case .top:
            return CGSize(width: offset.width, height: offset.height - paddingVertical)
        case .topTrailing:
            return CGSize(
                width: offset.width + paddingHorizontal - diagonalHPadding,
                height: offset.height - paddingVertical + diagonalVPadding
            )
        case .leading:
            return CGSize(width: offset.width - paddingHorizontal, height: offset.height)
        case .center:
            return CGSize(width: offset.width, height: offset.height)
        case .trailing:
            return CGSize(width: offset.width + paddingHorizontal, height: offset.height)
        case .bottomLeading:
            return CGSize(
                width: offset.width - paddingHorizontal + diagonalHPadding,
                height: offset.height + paddingVertical - diagonalVPadding
            )
        case .bottom:
            return CGSize(width: offset.width, height: offset.height + paddingVertical)
        case .bottomTrailing:
            return CGSize(width: offset.width + paddingHorizontal * sin(45), height: offset.height + paddingVertical * sin(45))
        default:
            return CGSize(width: offset.width, height: offset.height)
        }
    }
    
    private func getLineOffset(alignment: Alignment, padding: CGFloat) -> CGSize {
        let paddingHorizontal = -labelSize.width / 2 - textPadding / 2
        let paddingVertical = -labelSize.height / 2 - textPadding / 2
        let diagonalHPadding = padding * (sqrt(2) - 1) * sin(45) - borderLineWidth / 2
        let diagonalVPadding = padding * (sqrt(2) - 1) * sin(45) - borderLineWidth / 2
        switch alignment {
        case .topLeading:
            return CGSize(width: -paddingHorizontal - diagonalHPadding, height: -paddingVertical - diagonalVPadding)
        case .top:
            return CGSize(width: .zero, height: -paddingVertical)
        case .topTrailing:
            return CGSize(width: paddingHorizontal + diagonalHPadding, height: -paddingVertical - diagonalVPadding)
        case .leading:
            return CGSize(width: -paddingHorizontal, height: .zero)
        case .center:
            return .zero
        case .trailing:
            return CGSize(width: paddingHorizontal, height: .zero)
        case .bottomLeading:
            return CGSize(width: -paddingHorizontal - diagonalHPadding, height: paddingVertical + diagonalVPadding)
        case .bottom:
            return CGSize(width: .zero, height: paddingVertical)
        case .bottomTrailing:
            return CGSize(width: paddingHorizontal - diagonalHPadding, height: paddingVertical - diagonalVPadding)
        default:
            return .zero
        }
    }
    
    private func getDirection(alignment: Alignment) -> Direction {
        switch alignment {
        case .topLeading:
            return .diagonalDown
        case .top:
            return .vertical
        case .topTrailing:
            return .diagonalUp
        case .leading:
            return .horizontal
        case .center:
            return .vertical
        case .trailing:
            return .horizontal
        case .bottomLeading:
            return .diagonalUp
        case .bottom:
            return .vertical
        case .bottomTrailing:
            return .diagonalDown
        default:
            return .horizontal
        }
    }
}

extension MagnificationHelper {
    enum Direction {
        case horizontal, vertical, diagonalDown, diagonalUp
    }
    
    struct Line: Shape {
        let direction: Direction
        func path(in rect: CGRect) -> Path {
            var path = Path()
            switch direction {
            case .horizontal:
                path.move(to: CGPoint(x: rect.minX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            case .vertical:
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            case .diagonalDown:
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            case .diagonalUp:
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            }
            
            return path
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var scale: CGFloat = 1.5
        @State var positionTabs: CGSize = CGSize(width: 0.589, height: 0.092)
        @State var positionColorStrip: CGSize = CGSize(width: 0.63, height: 0.82)
        @State var positionRangeControl: CGSize = CGSize(width: 0.43, height: 0.82)
        @State var positionSelectorVideo: CGSize = CGSize(width: 0.12, height: 0.21)
        @State var positionExportTab: CGSize = CGSize(width: 0.845, height: 0.18)
        @State var positionPlayhead: CGSize = CGSize(width: 0.838, height: 0.75)
        @State var magnificationSize: CGSize = CGSize(width: 100, height: 100)
        @State var imageSize: CGSize = .zero
        @State var isShowTabs = false
        @State var isShowVideoSelection = false
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        var body: some View {
                Image("GrabQueueOverview")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .magnification(title: "Tabs", scale: scale, size: magnificationSize, position: positionTabs, alignment: .bottom, isShow: $isShowTabs)
                    .magnification(title: "Color Strip", scale: scale, size: magnificationSize, position: positionColorStrip, alignment: .top)
                    .magnification(title: "Part selection", scale: scale, size: magnificationSize, position: positionRangeControl, alignment: .leading)
                    .magnification(title: "Video selection", scale: scale - 1, size: magnificationSize, position: positionSelectorVideo, alignment: .trailing, isShow: $isShowVideoSelection)
                    .magnification(title: "Export Tabs", scale: scale - 1, size: magnificationSize, position: positionExportTab, alignment: .bottomLeading)
                    .magnification(title: "Playhead", scale: scale, size: magnificationSize, position: positionPlayhead, alignment: .topTrailing)
                    .onReceive(timer) { _ in
                        let showers = [$isShowTabs, $isShowVideoSelection]
                        if let isShowIndex = showers.firstIndex(where: { $0.wrappedValue == false }) {
                            showers[isShowIndex].wrappedValue = true
                        } else {
                            timer.upstream.connect().cancel()
                        }
                    }
        }
    }
    
    return PreviewWrapper()
        .frame(width: AppGrid.minWidthOverview, height: AppGrid.minHeightOverview)
        .padding()
}
