//
//  StripCountView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.12.2022.
//

import SwiftUI

struct StripCountView: View {
    
    var count: Int
    
    let pallets: [Image] = [
        Image("1"),
        Image("2"),
        Image("3"),
        Image("4"),
        Image("5"),
        Image("6"),
        Image("7"),
        Image("8")
    ]
    
    var body: some View {
        HStack(alignment: .center, spacing: Grid.pt8) {
            pallets[count - 1]
            HStack {
                Text("\(count)")
            }
            
        }
    }
}

struct StripCountView_Previews: PreviewProvider {
    static var previews: some View {
        StripCountView(count: 4)
    }
}
