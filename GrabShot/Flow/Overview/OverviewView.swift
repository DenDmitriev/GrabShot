//
//  OverviewView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.08.2023.
//

import SwiftUI

struct OverviewView: View {
    var body: some View {
        VStack {
            Text("Добро пожаловать")
                .font(.title)
            
            Text("""
GrabShot умеет создавать скриншоты с заданным интервалом секунд из видео файлов. Для этого нужно перетащить и бросить файл в вкладку Бросить видео или Файл - Выбрать Видео. Приложение имеет доступ только к папкам Загрузки, Изображения и Фильмы, поэтому может работать с видео файлами расположенными только в этих папках пользователя.
""")
            
            Text("")
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView()
            .previewLayout(.fixed(width: Grid.pt512, height: Grid.pt512))
    }
}
