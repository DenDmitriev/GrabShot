//
//  SettingsStripView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct SettingsStripView: View {
    
    var body: some View {
        
        VideoStripSettingsView()
            .padding(.all)
        
        ImageStripSettingsView()
            .padding(.all)
        
        Spacer()
    }
}

struct SettingsStripView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsStripView()
    }
}
