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
                .frame(maxWidth: Grid.pt128)
            
            Text("Welcome to GrabShot")
                .padding(.top)
                .font(.system(size: Grid.pt32))
            
            OverviewTitle(title: "An application for capturing frames from videos and extracting colors", caption: "To get acquainted with the main functions of the application, click next or close the window")
        }
    }
}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage()
    }
}
