//
//  StripView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2022.
//

import SwiftUI

struct StripView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var colors: [Color]
    @State var showCloseButton: Bool
    
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
            if showCloseButton {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .padding(Grid.pt4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(Grid.pt4)
                }
                .buttonStyle(.plain)
                .padding()
            }
        }
    }
}

struct StripView_Previews: PreviewProvider {
    static var previews: some View {
        StripView(colors: .constant(Video.placeholder.colors!), showCloseButton: true)
            .previewLayout(.fixed(width: Grid.pt256, height: Grid.pt256))
    }
}
