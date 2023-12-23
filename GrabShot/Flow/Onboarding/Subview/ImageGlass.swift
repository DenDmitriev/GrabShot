//
//  ImageGlass.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct ImageGlass: View {
    let image: String
    
    init(_ image: String) {
        self.image = image
    }
    
    var body: some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .cornerRadius(AppGrid.pt8)
            .shadow(radius: AppGrid.pt8)
    }
}

struct ImageGlass_Previews: PreviewProvider {
    static var previews: some View {
        ImageGlass("ColorPickerOverview")
    }
}
