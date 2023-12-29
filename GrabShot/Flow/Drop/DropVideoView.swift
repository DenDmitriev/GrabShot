//
//  DropView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.12.2023.
//

import SwiftUI

struct DropVideoView: View {
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "film.stack")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(maxWidth: AppGrid.pt64)
                
                Image(systemName: "arrow.down")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(maxWidth: AppGrid.pt32)
                    .offset(y: -AppGrid.pt18)
            }
            
            Text("Drag&Drop")
                .foregroundColor(.gray)
                .font(.title)
                .fontWeight(.light)
                .padding(.top)
        }
    }
}

#Preview {
    DropVideoView()
}
