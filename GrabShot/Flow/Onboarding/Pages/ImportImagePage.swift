//
//  ImportImagePage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct ImportImagePage: View {
    
    private var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .center) {
            OverviewTitle(title: "Import images", caption: "To start working with images, import the files. There are several options:")
            
            Spacer()
            
            LazyVGrid(columns: columns, spacing: Grid.pt8) {
                OverviewDetail(description: "Drag files to the image colors tab", image: "DropImageOverview")
                OverviewDetail(description: "Import files via the application menu", image: "ImportImageOverview")
            }
            .padding()
            
            Spacer()
        }
    }
}

struct ImportImagePage_Previews: PreviewProvider {
    static var previews: some View {
        ImportImagePage()
    }
}
