//
//  OverviewDetail.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct OverviewDetail: View {
    
    var description: String
    var image: String
    
    var body: some View {
        VStack {
            Text(NSLocalizedString(description, comment: "Overview"))
                .font(.title3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            Image(image)
                .resizable()
                .scaledToFit()
                .cornerRadius(AppGrid.pt16)
        }
        .padding(.horizontal)
    }
}

struct OverviewDetail_Previews: PreviewProvider {
    static var previews: some View {
        OverviewDetail(description: "Перетащите файлы в вкладку бросить видео", image: "DropVideoOverview")
    }
}
