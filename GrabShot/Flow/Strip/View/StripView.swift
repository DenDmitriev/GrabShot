//
//  StripView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2022.
//

import SwiftUI

struct StripView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var colors: [Color]
    
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
        .overlay(alignment: .topTrailing) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .padding(AppGrid.pt4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(AppGrid.pt4)
            }
            .buttonStyle(.borderless)
            .padding()
        }
        .frame(
            minWidth: AppGrid.minWidth / 1.3,
            maxWidth: AppGrid.minWidth / 1.1,
            minHeight: AppGrid.pt256,
            maxHeight: AppGrid.pt512
        )
    }
}

struct StripView_Previews: PreviewProvider {
    static var previews: some View {
        StripView(colors: Video.placeholder.colors!)
            .previewLayout(.fixed(width: AppGrid.pt256, height: AppGrid.pt256))
    }
}
