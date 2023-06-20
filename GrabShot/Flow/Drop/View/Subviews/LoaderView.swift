//
//  LoaderView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct LoaderView: View {
    var body: some View {
        GeometryReader { reader in
            
            ZStack {
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                .frame(width: reader.size.width, height: reader.size.height)
                
                ProgressView()
                    .progressViewStyle(.circular)
            }
            
        }
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
            .previewLayout(.fixed(width: 500, height: 500))
    }
}

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
