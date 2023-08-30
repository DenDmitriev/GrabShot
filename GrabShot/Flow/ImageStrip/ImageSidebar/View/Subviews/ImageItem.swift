//
//  ImageItem.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageItem: View {
    
    @State var nsImage: NSImage
    @State var title: String
    
    var body: some View {
        VStack {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
            
            Text(title)
            
        }
    }
}

//struct ImageItem_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageItem()
//    }
//}
