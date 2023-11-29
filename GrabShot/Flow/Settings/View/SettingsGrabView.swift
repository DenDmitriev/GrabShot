//
//  SettingsGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct SettingsGrabView: View {
    
    @EnvironmentObject var videoStore: VideoStore
    
    @ObservedObject private var viewModel: SettingsModel
    
    @AppStorage(DefaultsKeys.openDirToggle)
    private var openDirToggle: Bool = true
    
    @AppStorage(DefaultsKeys.quality)
    private var quality: Double = 70 // %
    
    @AppStorage(DefaultsKeys.createFolder)
    private var createFolder: Bool = true
    
    init() {
        self.viewModel = SettingsModel()
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
        let store = VideoStore()
        SettingsGrabView()
            .environmentObject(store)
    }
}
