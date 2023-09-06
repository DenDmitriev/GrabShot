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
            OverviewTitle(title: "Control panel", caption: "Приложение имеет рабочие пространства.")
            
            Spacer()
            
            LazyVGrid(columns: columns) {
                OverviewDetail(description: "Для выбора рабочего пространства используйте панель навигации по вкладкам.", image: "ControlPanelOverview")
                
                OverviewDetail(description: "Для изменения настроек приложения нажмите на шестерню.", image: "SettingsOverview")
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
