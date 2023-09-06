//
//  OverviewTitle.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct OverviewTitle: View {
    
    var title: String
    var caption: String
    
    var body: some View {
        VStack(spacing: Grid.pt4) {
            Text(title)
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
            
            Text(caption)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                
        }
        .padding(Grid.pt16)
    }
}

struct OverviewTitle_Previews: PreviewProvider {
    static var previews: some View {
        OverviewTitle(title: "Импорт видео", caption: "Для начала работы с видео импортируйте файлы.\nДля этого есть несколько вариантов:")
    }
}
