//
//  ColorPickerItem.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.08.2023.
//

import SwiftUI

struct ColorPickerItem: View {
    
    @Binding var bgColor: Color
    
    var body: some View {
        VStack {
            ColorPicker("Pick color", selection: $bgColor)
                .labelsHidden()
                .shadow(radius: Grid.pt8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bgColor)
    }
}

struct ColorPickerItem_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerItem(bgColor: .constant(.gray))
    }
}
