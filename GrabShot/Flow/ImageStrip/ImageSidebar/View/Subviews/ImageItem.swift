//
//  ImageItem.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageItem: View {
    
    @State var url: URL
    @State var title: String
    
    var body: some View {
        VStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "photo")
                    .symbolVariant(.fill)
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .background(background)
            }
            
            Text(title)
        }
    }
    
    var background: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary)
    }
}

//struct ImageItem_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageItem()
//    }
//}
