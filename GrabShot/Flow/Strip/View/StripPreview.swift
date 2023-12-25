//
//  StripPreview.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.12.2023.
//

import SwiftUI

struct StripPreview: View {
    
    @Binding var colors: [Color]
    var showAction: (() -> Void)
    @AppStorage(DefaultsKeys.stripViewMode)
    private var stripMode: StripMode = .strip
    
    var body: some View {
        HStack(spacing: .zero) {
            if colors.isEmpty {
                ZStack(content: {
                    Rectangle()
                        .fill(.black)
                        .frame(maxWidth: .infinity)
                    
                    Text("Empty")
                        .font(.title)
                        .foregroundColor(.gray)
                })
                
            } else {
                switch stripMode {
                case .strip:
                    ForEach(Array(zip(colors.indices ,colors)), id: \.0) { index, color in
                        Rectangle()
                            .fill(color)
                    }
                    .animation(.easeIn, value: colors)
                case .gradient:
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: .init(colors: colors),
                                startPoint: .init(x: 0, y: 0),
                                endPoint: .init(x: 1, y: 0)
                            )
                        )
                }
            }
        }
        .overlay(alignment: .trailing) {
            Button {
                showAction()
            } label: {
                Image(systemName: "barcode.viewfinder")
                    .padding(AppGrid.pt4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(AppGrid.pt4)
            }
            .buttonStyle(.borderless)
            .padding()
        }
    }
}

#Preview {
    StripPreview(colors: .constant(Video.placeholder.colors!), showAction: {})
}
