//
//  WelcomePage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        VStack {
            Image("AppIcon256")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Grid.pt64)
            
            Text("Добро пожаловать в GrabShot")
                .padding(.top)
                .font(.system(size: Grid.pt32))
            
            OverviewTitle(title: "Приложение для захвата кадров из видео и извлечения цвета.", caption: "Для знакомства с основными функциями приложения нажмите далее или закройте окно чтоб начать сразу.")
        }
    }
}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage()
    }
}
