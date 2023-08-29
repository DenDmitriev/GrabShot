//
//  ImageSidebar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageSidebar: View {
    
    @ObservedObject var viewModel: ImageSidebarModel
    @State private var imageStrips: [ImageStrip] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(imageStrips, id: \.self) { imageStrip in
                    NavigationLink {
                        ImageStripView(imageStrip: imageStrip)
                            .environmentObject(viewModel)
                    } label: {
                        ImageItem(nsImage: imageStrip.nsImage, title: imageStrip.title)
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .onReceive(viewModel.imageStore.$imageStrips, perform: { imageStrips in
            self.imageStrips = imageStrips
        })
        .onDrop(of: [.image], delegate: viewModel.dropDelegate)
    }
}

struct ImageSidebar_Previews: PreviewProvider {
    static var previews: some View {
        ImageSidebar(viewModel: ImageSidebarModel())
    }
}
