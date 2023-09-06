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
            OverviewTitle(title: "Control panel", caption: "The application has workspaces.")
            
            Spacer()
            
            LazyVGrid(columns: columns) {
                OverviewDetail(description: "To select a workspace, use the tab navigation bar.", image: "ControlPanelOverview")
                
                OverviewDetail(description: "To change the application settings, click on the gear.", image: "SettingsOverview")
            }
            
            Spacer()
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
