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
        VStack(alignment: .center, spacing: AppGrid.pt16) {
            OverviewTitle(title: "Importing images", caption: "To get started with images, import the files. There are several options:")
            
            Spacer()
            
            HStack(spacing: AppGrid.pt8) {
                OverviewDetail(description: "Drag and drop files to the Image Colors tab", image: "DropImageOverview")
                OverviewDetail(description: "Import files via the application menu", image: "ImportImageOverview")
            }
            .padding()
            
            HStack(spacing: AppGrid.pt8) {
                OverviewDetail(description: "Import files via the context menu in Grab tab", image: "ImporGrabbedImageOverview")
                    .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Key combination")
                        .font(.title3)
                    
                    HStack {
                        Image(systemName: "command")
                        Text("+").font(.title3)
                        Text("I")
                    }
                    .frame(maxHeight: .infinity)
                    .font(.title)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ImportImagePage_Previews: PreviewProvider {
    static var previews: some View {
        ImportImagePage()
    }
}
