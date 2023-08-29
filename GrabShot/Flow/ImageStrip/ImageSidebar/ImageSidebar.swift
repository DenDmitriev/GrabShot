//
//  ImageSidebar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageSidebar: View {
    
    @ObservedObject var viewModel: ImageSidebarModel
    @State private var nsImages: [NSImage] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(nsImages, id: \.self) { nsImage in
                    NavigationLink {
                        ImageStripView(nsImage: nsImage)
                            .environmentObject(viewModel)
                    } label: {
                        ImageItem(nsImage: nsImage, title: "Title")
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .onReceive(viewModel.imageStore.$nsImages, perform: { nsImages in
            self.nsImages = nsImages
        })
        .onDrop(of: [.image], delegate: viewModel.dropDelegate)
    }
}

struct ImageSidebar_Previews: PreviewProvider {
    static var previews: some View {
        ImageSidebar(viewModel: ImageSidebarModel())
    }
}
