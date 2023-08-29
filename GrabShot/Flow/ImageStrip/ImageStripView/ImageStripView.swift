//
//  ImageStrip.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStripView: View {
    
    @EnvironmentObject var imageSidebarModel: ImageSidebarModel
    @State var nsImage: NSImage
    @State var colors: [Color] = []
    @State var hasColors = false
    
    @AppStorage(UserDefaultsService.Keys.stripImageHeight)
    private var stripImageHeight: Double = Grid.pt32
    
    @AppStorage(UserDefaultsService.Keys.stripCountImage)
    private var stripCountImage: Int = 8
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: .zero) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .onAppear {
                        if let colors = StripManagerImage.getAverageColors(nsImage: nsImage, colorCount: stripCountImage) {
                            self.colors = colors
                            hasColors = true
                        }
                    }
                if hasColors {
                    StripPalleteView(count: stripCountImage, colors: colors)
                        .frame(height: stripImageHeight)
                }
                
            }
            .frame(minWidth: Grid.pt256, minHeight: Grid.pt256)
            .onDrop(of: [.image], delegate: imageSidebarModel.dropDelegate)
        }
    }
}

//struct ImageStrip_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageStripView(viewModel: ImageStripModel(), nsImage: <#NSImage#>)
//    }
//}
