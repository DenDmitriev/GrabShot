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
            OverviewTitle(title: "Импорт изображений", caption: "Для начала работы с изображениями импортируйте файлы.\nДля этого есть несколько вариантов:")
            
            Spacer()
            
            LazyVGrid(columns: columns, spacing: Grid.pt8) {
                OverviewDetail(description: "Перетащите файлы в вкладку цвета изображения", image: "DropImageOverview")
                OverviewDetail(description: "Импортируйте файлы через меню приложения", image: "ImportImageOverview")
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
