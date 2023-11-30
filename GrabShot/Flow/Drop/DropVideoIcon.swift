//
//  DropVideoIcon.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.08.2023.
//

import SwiftUI

struct DropVideoIcon: View {
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "film.stack")
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
            
            Text("Drag&Drop")
                .foregroundColor(.gray)
                .font(.title)
                .fontWeight(.light)
                .padding(.top)
        }
    }
}

struct DropVideoIcon_Previews: PreviewProvider {
    static var previews: some View {
        DropVideoIcon()
    }
}
