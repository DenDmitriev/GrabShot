//
//  ColorPickerItem.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.08.2023.
//

import SwiftUI
import DominantColors
import UniformTypeIdentifiers
//import AppKit

struct ColorPickerItem: View {
    
    @Binding var bgColor: Color
    @State private var description: String = "#000000"
    private let pasteboard = NSPasteboard.general
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ColorPicker("Pick color", selection: $bgColor)
                    .labelsHidden()
                    .shadow(radius: AppGrid.pt8)
                    .help("Select custom color")

                Text(description)
                .onChange(of: bgColor, perform: { newValue in
                    description = Self.description(color: bgColor)
                })
                .onAppear {
                    description = Self.description(color: bgColor)
                }
                .font(.callout)
                .buttonStyle(.borderless)
                .padding(AppGrid.pt4)
                .background(.regularMaterial)
                .cornerRadius(AppGrid.pt4)
                .fontWeight(.bold)
                .contextMenu {
                    Button("Copy color") {
                        pasteboard.clearContents()
                        var string = description
                        string.removeFirst()
                        pasteboard.setString(string, forType: .string)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgColor)
        }
    }
    
    static func description(color: Color) -> String {
        if let cgColor = color.cgColor {
            let hexColor = Hex(cgColor: cgColor)
            return hexColor.hex
        } else {
            return ""
        }
    }
}

struct ColorPickerItem_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerItem(bgColor: .constant(.yellow))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
