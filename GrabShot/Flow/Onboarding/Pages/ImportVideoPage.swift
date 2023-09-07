//
//  ImportVideoPage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct ImportVideoPage: View {
    
    private var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .center) {
            OverviewTitle(title: "Video import", caption: "To get started with the video, import the files. There are several options for this:")
            
            Spacer()
            
            LazyVGrid(columns: columns, spacing: Grid.pt16) {
                OverviewDetail(description: "Drag and drop files to the Drop video tab", image: "DropVideoOverview")
                OverviewDetail(description: "Drag and drop files to the Grab queue tab", image: "DropTableVideoOverview")
                OverviewDetail(description: "Import files via the application menu", image: "ImportVideoOverview")
            }
            .padding()
            
            Spacer()
        }
    }
}

struct ImportVideoPage_Previews: PreviewProvider {
    static var previews: some View {
        ImportVideoPage()
    }
}
