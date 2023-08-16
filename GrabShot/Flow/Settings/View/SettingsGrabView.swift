//
//  SettingsGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct SettingsGrabView: View {
    
    @ObservedObject private var viewModel: SettingsModel
    
    @State private var openDirToggle: Bool
    @State private var quality: CGFloat
    
    init() {
        self.viewModel = SettingsModel()
        self.openDirToggle = Session.shared.openDirToggle
        self.quality = Session.shared.quality
    }
    
    var body: some View {
        GroupBox {
            VStack {
                HStack(spacing: Grid.pt32) {
                    VStack(alignment: .leading) {
                        Text("Quality")
                        
                        Text("Grab shots compression ratio")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("\(Int(quality)) %")
                            .foregroundColor(.gray)
                        
                        Slider(value: $quality, in: 1...100)
                            .onChange(of: quality) { newValue in
                                viewModel.updateQuality(newValue)
                            }
                    }
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Open folder")
                        
                        Text("Open folder with shots after capture")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $openDirToggle)
                        .onChange(of: openDirToggle) { newValue in
                            viewModel.updateOpenDirToggle(value: newValue)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
            }
            .padding(.all, Grid.pt6)
        } label: {
            Text("Grab settings")
        }
        .padding(.all)
        
        Spacer()
    }
}

struct SettingsGrabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsGrabView()
    }
}
