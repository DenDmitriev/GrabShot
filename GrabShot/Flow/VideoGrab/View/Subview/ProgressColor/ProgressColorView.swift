//
//  ProgressColorView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI

struct ProgressColorView: View {
    @Binding var progress: Int
    @Binding var total: Int
    @Binding var colors: [Color]
    @State var stripMode: StripMode = .liner
    @Environment(\.colorScheme) private var colorScheme
    private let height: CGFloat = AppGrid.pt12
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(
                        .shadow(.inner(color: .black.opacity(0.2), radius: 3, x: 3, y: 3))
                        .shadow(.inner(color: .white.opacity(0.2), radius: 3, x: -3, y: -3))
                    )
                    .foregroundStyle(.background)
                
                HStack(spacing: .zero) {
                    switch stripMode {
                    case .liner:
                        ForEach(colors.indices, id: \.self) { index in
                            Rectangle()
                                .fill(colors[index])
                        }
                    case .gradient:
                        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: .init(colors: colors),
                                    startPoint: .init(x: 0, y: 0),
                                    endPoint: .init(x: 1, y: 0)
                                )
                            )
                    }
                }
                .overlay(content: {
                    ZStack {
                        switch colorScheme {
                        case .light:
                            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                                .fill(.shadow(.inner(color: .white, radius: 3, x: 3, y: 3)))
                                .blendMode(.screen)
                        case .dark:
                            RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                                .fill(.shadow(.inner(color: .black, radius: 3, x: -3, y: -3)))
                                .blendMode(.multiply)
                        default:
                            EmptyView()
                        }
                    }
                })
                .animation(.smooth, value: colors)
                .animation(.easeIn, value: progress)
                .frame(width: min(geometry.size.width * (Double(progress) / Double(total)), geometry.size.width))
                .clipShape(RoundedRectangle(cornerRadius: height / 2))
                .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: height / 2))
    }
}

#Preview {
    @State var progress: Int = 50
    @State var total: Int = 100
    
    return Group {
        ProgressColorView(progress: $progress, total: $total, colors: .constant(Video.placeholder.grabColors), stripMode: .liner)
            .padding()
        
        ProgressColorView(progress: $progress, total: $total, colors: .constant(Video.placeholder.grabColors), stripMode: .gradient)
            .padding()
    }
}
