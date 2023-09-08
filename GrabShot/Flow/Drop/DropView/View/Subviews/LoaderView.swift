//
//  LoaderView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct LoaderView: View {
    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
            
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
            .previewLayout(.fixed(width: Grid.pt512, height: Grid.pt512))
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
