//
//  ImageSidebarProgressView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.09.2023.
//

import SwiftUI

struct ImageSidebarProgressView: View {
    
    @State private var current: Int = .zero
    @State private var total: Int = .zero
    @EnvironmentObject var viewModel: ImageSidebarModel
    
    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
            
            ProgressView(
                value: Double(current),
                total: Double(total)
            )
            .progressViewStyle(BagelProgressStyle())
            .onReceive(viewModel.imageRenderService.progress.$total) { total in
                self.total = total
            }
            .onReceive(viewModel.imageRenderService.progress.$current) { current in
                withAnimation {
                    self.current = current
                }
            }
            .frame(maxWidth: AppGrid.pt64, maxHeight: AppGrid.pt64)
        }
    }
}

struct ImageSidebarProgressView_Previews: PreviewProvider {
    static var previews: some View {
        let store = ImageStore()
        ImageSidebarProgressView()
            .environmentObject(ImageSidebarModelBuilder.build(store: store, score: ScoreController(caretaker: Caretaker())))
    }
}
