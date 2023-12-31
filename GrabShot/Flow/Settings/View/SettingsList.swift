//
//  SettingsList.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct SettingsList: View {
    
    @State private var selection: Int?
    
    var body: some View {
        
        NavigationView {
            List(selection: $selection) {
                NavigationLink(destination: SettingsGrabView()) {
                    Text("Grab")
                }
                .tag(0)

                NavigationLink(destination: SettingsStripView()) {
                    Text("Strip")
                }
                .tag(1)
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.selection = .zero
                }
            }
            
            Text("Select menu")
        }
        .frame(minWidth: Grid.pt512, minHeight: Grid.pt300)
    }
}

struct SettingsList_Previews: PreviewProvider {
    static var previews: some View {
        SettingsList()
    }
}
