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
            OverviewTitle(title: "Импорт видео", caption: "Для начала работы с видео импортируйте файлы.\nДля этого есть несколько вариантов:")
            
            Spacer()
            
            LazyVGrid(columns: columns, spacing: Grid.pt8) {
                OverviewDetail(description: "Перетащите файлы в вкладку бросить видео", image: "DropVideoOverview")
                OverviewDetail(description: "Перетащите файлы в вкладку очередь захвата", image: "DropTableVideoOverview")
                OverviewDetail(description: "Импортируйте файлы через меню приложения", image: "ImportVideoOverview")
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
