//
//  InterfacePage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct InterfacePage: View {
    
    private var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .center) {
            OverviewTitle(title: "Control panel", caption: "There are workspaces in the application")
            
            Spacer()
            
            VStack {
                HStack {
                    Text("To select a workspace, use the tab navigation bar")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("To change the application settings, click on the gear")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                GeometryReader { geometry in
                    let minHeight = geometry.size.height / 12
                    let maxHeight = geometry.size.height / 6
                    Image("GrabQueueOverview")
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(Grid.pt16)
                        .overlay(alignment: .top) {
                            ImageGlass("ControlPanelOverview")
                                .frame(minHeight: minHeight * 1.5, maxHeight: maxHeight * 1.5)
                        }
                        .overlay(alignment: .topTrailing) {
                            ImageGlass("SettingsOverview")
                                .frame(minHeight: minHeight * 1.5, maxHeight: maxHeight * 1.5)
                    }
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct InterfacePage_Previews: PreviewProvider {
    static var previews: some View {
        InterfacePage()
    }
}
