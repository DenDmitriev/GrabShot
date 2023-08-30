//
//  DropImageIcon.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct DropImageIcon: View {
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "photo.stack")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(maxWidth: Grid.pt64)
                
                Image(systemName: "arrow.down")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(maxWidth: Grid.pt32)
                    .offset(y: -Grid.pt18)
            }
            
            Text("Drag&Drop Images")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .font(.largeTitle)
                .fontWeight(.light)
                .padding(.top)
        }
    }
}

struct DropImageIcon_Previews: PreviewProvider {
    static var previews: some View {
        DropImageIcon()
    }
}
