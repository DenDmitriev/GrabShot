//
//  SettingsGeneralView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2023.
//

import SwiftUI

struct SettingsGeneralView: View {
    
    @Binding var showAlert: Bool
    @Binding var message: String?
    
    var body: some View {
        ScrollView {
            CacheThumbnailSettingsView(showAlert: $showAlert, message: $message)
                .padding(.all)
        }
    }
}

#Preview {
    SettingsGeneralView(showAlert: .constant(false), message: .constant(nil))
        .environmentObject(SettingsModel())
}
