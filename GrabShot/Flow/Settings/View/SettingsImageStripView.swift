//
//  SettingsImageStripView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 28.03.2024.
//

import SwiftUI

struct SettingsImageStripView: View {
    
    var body: some View {
        ScrollView {
            SettingsImageStripExportView()
                .padding(.all)
        }
    }
}

#Preview {
    SettingsImageStripView()
}
