//
//  GrabOverviewPage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct GrabOverviewPage: View {
    
    private var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .center) {
            OverviewTitle(title: "Frame grabbing", caption: "After importing the video, you are taken to the capture queue tab")
            
            Spacer()
            
            VStack {
                Text("The window consists of a table of imported videos. The first step is to select the export folder. Next, decide on the assortment, you can choose an excerpt or the whole. Specify the frame capture interval in seconds. Finally, click the Start button and manage the process.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                GeometryReader { geometry in
                    let minHeight = geometry.size.height / 12
                    let maxHeight = geometry.size.height / 6
                    VStack {
                        Image("GrabQueueOverview")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(Grid.pt16)
                            .overlay(alignment: .trailing) {
                                
                                    ImageGlass("GrabPeriodOverview")
                                        .frame(minHeight: minHeight, maxHeight: maxHeight)
                                        .offset(y: geometry.size.height / 24)
                            }
                            .overlay(alignment: .top) {
                                HStack {
                                    ImageGlass("GrabOutputOverview")
                                        .frame(minHeight: minHeight * 1.5, maxHeight: maxHeight * 1.5)
                                    
                                    ImageGlass("GrabRangeOverview")
                                        .frame(minHeight: minHeight * 1.5, maxHeight: maxHeight * 1.5)
                                }
                            }
                            .overlay(alignment: .bottomTrailing) {
                                
                                    ImageGlass("GrabControlOverview")
                                    .frame(minHeight: minHeight * 1.7, maxHeight: maxHeight * 1.7)
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

struct GrabOverviewPage_Previews: PreviewProvider {
    static var previews: some View {
        GrabOverviewPage()
    }
}
