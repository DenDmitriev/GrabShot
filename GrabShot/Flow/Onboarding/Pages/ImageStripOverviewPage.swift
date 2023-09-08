//
//  ImageStripOverviewPage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct ImageStripOverviewPage: View {
    
    private var columnsChoose = [GridItem(.flexible())]
    private var columnsExport = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .center) {
            OverviewTitle(title: "Extract color", caption: "Select the image colors tab")
            
            Spacer()
            
            VStack {
                Text("After importing the images, select the desired frame in the left navigation bar. The frame will appear in the working window. Choose one of the methods and algorithms for color selection. If you want to exclude black and white colors, then select the desired option. To pin the result under the image, click export or export all.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                GeometryReader { geometry in
                    let minHeight = geometry.size.height / 12
                    let maxHeight = geometry.size.height / 6
                    VStack {
                        Image("ImageStripOverview")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(Grid.pt16)
                            .overlay(alignment: .bottomTrailing) {
                                ImageGlass("ImageExportOverview")
                                    .frame(minHeight: minHeight, maxHeight: maxHeight)
                            }
                            .overlay(alignment: .bottomLeading) {
                                ImageGlass("ImagesExportOverview")
                                    .frame(minHeight: minHeight, maxHeight: maxHeight)
                            }
                            .overlay(alignment: .top) {
                                ImageGlass("ColorPickerOverview")
                                    .frame(minHeight: minHeight * 1.5, maxHeight: maxHeight * 1.5)
                            }
                            .overlay {
                                ImageGlass("ColorCopyOverView")
                                    .frame(minHeight: minHeight, maxHeight: maxHeight)
                                    .offset(y: geometry.size.height / 24)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                }
            }
            .padding(.horizontal)

            
            Spacer()
        }
    }
}

struct ImageStripOverviewPage_Previews: PreviewProvider {
    static var previews: some View {
        ImageStripOverviewPage()
    }
}
