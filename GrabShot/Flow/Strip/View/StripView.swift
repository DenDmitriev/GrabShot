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
    
    var body: some View {
        HStack(spacing: .zero) {
            if colors.isEmpty {
                Rectangle()
                    .fill(.black)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(Array(zip(colors.indices ,colors)), id: \.0) { index, color in
                    Rectangle()
                        .fill(color)
                }
                .animation(.easeInOut, value: colors)
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
