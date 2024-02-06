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
        VStack(alignment: .center, spacing: AppGrid.pt16) {
            OverviewTitle(title: "Video import", caption: "To get started with the video, import the files. There are several options for this:")
            
            HStack {
                OverviewDetail(description: "Drag and drop files to the Grab queue tab", image: "DropVideoOverview")
                
                VStack {
                    Text("Key combination")
                        .font(.title3)
                    
                    HStack {
                        Image(systemName: "command")
                        Text("+").font(.title3)
                        Text("O")
                    }
                    .frame(maxHeight: .infinity)
                    .font(.title)
                }
                .frame(maxWidth: .infinity)
                
            }
            
            HStack {
                OverviewDetail(description: "Import files via the application menu", image: "ImportVideoOverview")
                
                OverviewDetail(description: String(localized: "Импортируйте видео с Vimeo или Youtube."), image: "ImportVideoHostingOverview")
            }
        }
        .padding()
    }
}

struct ImportVideoPage_Previews: PreviewProvider {
    static var previews: some View {
        ImportVideoPage()
    }
}
