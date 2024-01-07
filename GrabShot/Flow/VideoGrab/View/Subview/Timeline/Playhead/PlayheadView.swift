//
//  PlayheadView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct PlayheadView: View {
    let head: CGFloat = 20
    let thickness: CGFloat = 4
    
    var body: some View {
        PlayheadShape(head: head, thickness: thickness)
            .fill(Color.accentColor)
            .frame(width: head + 5)
            .background {
                PlayheadShape(head: head, thickness: thickness)
                    .stroke(.black.opacity(0.25), style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round))
            }
    }
}

#Preview {
    PlayheadView()
        .frame(height: AppGrid.pt64)
        .padding()
}
